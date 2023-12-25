# typed: strict

require "sorbet-runtime"

class ResumeEntry
  extend T::Sig

  sig {returns(String)}
  attr_reader :name

  sig {returns(T::Hash[String, Integer])}
  attr_reader :appeal

  sig {returns(Integer)}
  attr_reader :lines

  sig {returns(String)}
  attr_reader :order

  sig {returns(String)}
  attr_reader :tex

  sig {returns(T::Array[String])}
  attr_reader :keywords

  sig {params(info: T::Hash[String, T.any(String, Integer, T::Array[String], T::Hash[String, Integer])]).void}
  def initialize(info)
    @name = T.let(T.cast(info["name"], String), String)
    @appeal = T.let(T.cast(info["appeal"], T::Hash[String, Integer]), T::Hash[String, Integer])
    @lines = T.let(T.cast(info["lines"], Integer), Integer)
    @order = T.let(T.cast(info["order"], String), String)
    @tex = T.let(T.cast(info["tex"], String), String)
    @keywords = T.let(
      (info.has_key? "keywords") ?
        T.cast(info["keywords"], T::Array[String]) :
        [],
      T::Array[String])
  end
end
