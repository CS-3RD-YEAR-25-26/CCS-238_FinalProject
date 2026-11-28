# Grammar Checker (Elixir version)
#
# Reads sentences from inputs/grammar/sentences.txt, checks each one
# against the same small English grammar as the Prolog version, and
# writes the results to output/elixir/grammar.txt.
#
# Run from the project folder:
#   elixir elixir/grammar/grammar.exs
#   elixir elixir/grammar/grammar.exs "the happy cat sleeps"
#
# The second form checks only the given sentence and prints the result
# without changing the output file.

defmodule Grammar do
  # ---------------------------------------------------------------------
  # Lexicon
  #
  # Module attributes (@name) are constants fixed when the module is
  # compiled. Maps link each word to its number; :any means the word
  # works with both singular and plural, which plays the role of an
  # unbound variable in the Prolog lexicon.
  # ---------------------------------------------------------------------

  @determiners %{
    "the" => :any,
    "a" => :singular,
    "every" => :singular,
    "two" => :plural,
    "many" => :plural
  }

  @nouns %{
    "dog" => :singular, "dogs" => :plural,
    "cat" => :singular, "cats" => :plural,
    "student" => :singular, "students" => :plural,
    "teacher" => :singular, "teachers" => :plural,
    "professor" => :singular, "professors" => :plural,
    "book" => :singular, "books" => :plural,
    "ball" => :singular, "balls" => :plural,
    "park" => :singular, "parks" => :plural
  }

  # ~w(...) is a sigil that splits the text on spaces into a list of
  # strings, so ~w(big small) is the same as ["big", "small"].
  @adjectives ~w(big small lazy happy old red)

  @verbs %{
    "chases" => {:singular, :transitive}, "chase" => {:plural, :transitive},
    "sees" => {:singular, :transitive}, "see" => {:plural, :transitive},
    "likes" => {:singular, :transitive}, "like" => {:plural, :transitive},
    "reads" => {:singular, :transitive}, "read" => {:any, :transitive},
    "chased" => {:any, :transitive},
    "sleeps" => {:singular, :intransitive}, "sleep" => {:plural, :intransitive},
    "runs" => {:singular, :intransitive}, "run" => {:plural, :intransitive},
    "laughs" => {:singular, :intransitive}, "laugh" => {:plural, :intransitive}
  }

  @prepositions ~w(in on with near)

  # ---------------------------------------------------------------------
  # Grammar rules
  #
  # Elixir has no built-in backtracking, so the search is written by
  # hand in "continuation-passing style". Every rule takes an extra
  # argument k, an anonymous function that says what to do next. When a
  # rule matches, it calls k with the tree it built and the words left
  # over. Whatever k returns is passed back up:
  #   - a tree means a full parse was found, and the search stops
  #   - nil or false means this path failed, so try the next alternative
  #
  # `a || b` runs b only if a is nil or false, so `first_try || second_try`
  # is how a rule moves on to its next alternative. This gives the same
  # depth-first order as Prolog, and stopping at the first success plays
  # the role of Prolog's cut.
  #
  # The anonymous functions (fn ... -> ... end) are closures: they can
  # use variables from the rule that created them, like det and adjs
  # below, even though they run later.
  #
  # Trees are tuples like {:np, [child, ...]} and are printed in the
  # same form as Prolog terms, e.g. np(det(the),n(dog)).
  # ---------------------------------------------------------------------

  # sentence -> noun_phrase verb_phrase
  # The subject's number is passed to verb_phrase so the verb can be
  # checked against it.
  def sentence(words, mode, k) do
    noun_phrase(words, mode, fn np, num, rest1 ->
      verb_phrase(rest1, mode, num, fn vp, rest2 ->
        k.({:s, [np, vp]}, rest2)
      end)
    end)
  end

  # noun_phrase -> determiner adjective* noun prep_phrase*
  # [head | tail] builds a list with head in front, and ++ joins two
  # lists, so parts that are missing simply do not appear in the tree.
  # `agree?(...) && ...` only continues when the numbers agree.
  def noun_phrase(words, mode, k) do
    determiner(words, fn det, det_num, rest1 ->
      adjectives(rest1, fn adjs, rest2 ->
        noun(rest2, fn noun, num, rest3 ->
          agree?(mode, det_num, num) &&
            prep_phrases(rest3, mode, fn pps, rest4 ->
              k.({:np, [det | adjs] ++ [noun | pps]}, num, rest4)
            end)
        end)
      end)
    end)
  end

  # verb_phrase -> verb object? prep_phrase*
  def verb_phrase(words, mode, subject_num, k) do
    verb(words, fn verb, verb_num, type, rest1 ->
      agree?(mode, verb_num, subject_num) &&
        object(rest1, mode, type, fn obj, rest2 ->
          prep_phrases(rest2, mode, fn pps, rest3 ->
            k.({:vp, [verb | obj] ++ pps}, rest3)
          end)
        end)
    end)
  end

  # Functions can have several clauses. Elixir picks the first clause
  # whose arguments match, so here the atom :transitive or
  # :intransitive decides which clause runs.
  defp object(words, mode, :transitive, k) do
    noun_phrase(words, mode, fn np, _num, rest -> k.([np], rest) end)
  end

  defp object(words, _mode, :intransitive, k), do: k.([], words)

  # Zero or more adjectives. The pattern [w | rest] splits the list into
  # its first word and the remaining words, and `= words` also keeps the
  # whole list. The guard `when w in @adjectives` only lets this clause
  # run when the first word is an adjective. Taking more adjectives is
  # tried first and taking none comes after ||, matching the clause
  # order in Prolog.
  defp adjectives([w | rest] = words, k) when w in @adjectives do
    adjectives(rest, fn adjs, rest2 -> k.([{:adj, [w]} | adjs], rest2) end) ||
      k.([], words)
  end

  defp adjectives(words, k), do: k.([], words)

  # Zero or more prepositional phrases. prep_phrase calls noun_phrase,
  # which calls prep_phrases again, so the rules are mutually recursive.
  defp prep_phrases(words, mode, k) do
    prep_phrase(words, mode, fn pp, rest1 ->
      prep_phrases(rest1, mode, fn pps, rest2 -> k.([pp | pps], rest2) end)
    end) || k.([], words)
  end

  defp prep_phrase([p | rest], mode, k) when p in @prepositions do
    noun_phrase(rest, mode, fn np, _num, rest2 ->
      k.({:pp, [{:prep, [p]}, np]}, rest2)
    end)
  end

  defp prep_phrase(_words, _mode, _k), do: nil

  # Single-word rules. Map.fetch/2 returns {:ok, value} or :error, and
  # `case` picks the branch whose pattern matches that result.
  defp determiner([w | rest], k) do
    case Map.fetch(@determiners, w) do
      {:ok, num} -> k.({:det, [w]}, num, rest)
      :error -> nil
    end
  end

  defp determiner([], _k), do: nil

  defp noun([w | rest], k) do
    case Map.fetch(@nouns, w) do
      {:ok, num} -> k.({:n, [w]}, num, rest)
      :error -> nil
    end
  end

  defp noun([], _k), do: nil

  defp verb([w | rest], k) do
    case Map.fetch(@verbs, w) do
      {:ok, {num, type}} -> k.({:v, [w]}, num, type, rest)
      :error -> nil
    end
  end

  defp verb([], _k), do: nil

  # In strict mode the two numbers must match unless one of them is
  # :any. In loose mode anything passes. Running the grammar again in
  # loose mode tells us whether a rejected sentence failed only because
  # of agreement.
  defp agree?(:loose, _a, _b), do: true
  defp agree?(:strict, a, b), do: a == :any or b == :any or a == b

  defp known_word?(w) do
    Map.has_key?(@determiners, w) or Map.has_key?(@nouns, w) or
      w in @adjectives or Map.has_key?(@verbs, w) or w in @prepositions
  end

  # ---------------------------------------------------------------------
  # Checking a sentence
  # ---------------------------------------------------------------------

  # Returns the first parse that uses up every word, or nil if there is
  # none. The last continuation only accepts a parse with no words left;
  # `if` without `else` returns nil, which makes the search try the next
  # alternative.
  defp first_parse(words, mode) do
    sentence(words, mode, fn tree, rest -> if rest == [], do: tree end)
  end

  # cond runs the first branch whose condition is truthy. Assigning
  # inside a condition (tree = ...) both tests the value and keeps it
  # for that branch.
  def classify(words) do
    cond do
      tree = first_parse(words, :strict) ->
        {:valid, tree}

      unknown = Enum.find(words, &(not known_word?(&1))) ->
        {:invalid, "unknown word '#{unknown}'"}

      first_parse(words, :loose) ->
        {:invalid, "number agreement error"}

      true ->
        {:invalid, "does not match the grammar"}
    end
  end

  # The pipe operator |> passes the result of one step as the first
  # argument of the next, so the steps read top to bottom.
  # The regex removes punctuation from both ends of each word, the same
  # characters the Prolog version strips.
  def tokenize(line) do
    line
    |> String.downcase()
    |> String.split([" ", "\t"])
    |> Enum.map(&String.replace(&1, ~r/^[ \t.,!?;:"'()\-]+|[ \t.,!?;:"'()\-]+$/, ""))
    |> Enum.reject(&(&1 == ""))
  end

  # Builds one output line in the form:
  #   STATUS | sentence | parse tree or reason
  def result_line(line) do
    case classify(tokenize(line)) do
      {:valid, tree} -> "VALID | #{line} | #{render(tree)}"
      {:invalid, reason} -> "INVALID | #{line} | #{reason}"
    end
  end

  # Turns a tree tuple into Prolog-style text. The first clause matches
  # a {name, children} tuple and the second matches a plain word.
  defp render({name, children}), do: "#{name}(#{Enum.map_join(children, ",", &render/1)})"
  defp render(word) when is_binary(word), do: word

  # ---------------------------------------------------------------------
  # File input and output
  # ---------------------------------------------------------------------

  # __DIR__ is the folder this file is in, so the paths work no matter
  # where elixir is started from.
  defp check_file do
    input = Path.expand("../../inputs/grammar/sentences.txt", __DIR__)
    output = Path.expand("../../output/elixir/grammar.txt", __DIR__)

    results =
      input
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&result_line/1)

    File.write!(output, Enum.map_join(results, &(&1 <> "\n")))
    Enum.each(results, &IO.puts/1)
  end

  # With no arguments the whole input file is checked. Otherwise the
  # arguments are joined back into one sentence and only that sentence
  # is checked and printed; the output file is left alone.
  def main([]), do: check_file()
  def main(args), do: args |> Enum.join(" ") |> result_line() |> IO.puts()
end

# System.argv() is the list of words typed after the file name.
Grammar.main(System.argv())
