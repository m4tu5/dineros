# una version chiquita de Money que acepte muchas monedas
class Money
  attr_reader :currency, :cents

  def initialize(cents, currency)
    @currency = currency
    @cents = cents
  end

  def format
    "#{Money.thousands_separator(cents)} #{currency}"
  end

  def self.thousands_separator(cents, sep = '.', dec_sep = ',')
    int = (cents.abs.to_f / 100).to_i
    dec = ((cents.abs / BigDecimal(100)) - int)
    if dec == 0.0
      formato = "#{int}"
    else
      formato = "#{int}#{dec_sep}#{(dec * 100).to_i}"
    end

    if cents.to_s.chr == "-"
      formato.prepend("-")
    else
      formato
    end

  end
end
