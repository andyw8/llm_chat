module ApplicationHelper
  # Costs arrive as US dollars and are routinely a fraction of a cent, so the
  # usual two decimals would round every reply to $0.00. Show six decimals
  # under a cent. An absent amount means the provider published no pricing -
  # it is not a free call, so it never reads as $0.00.
  def cost_label(amount)
    return "—" if amount.nil?
    return "$0.00" if amount.zero?
    return "< $0.000001" if amount < 0.000001

    number_to_currency(amount, precision: amount < 0.01 ? 6 : 2)
  end

  def token_count_label(count)
    count.nil? ? "—" : number_with_delimiter(count)
  end

  # The token split behind a cost, for the title attribute on a reply's
  # figure: "1,200 in · 340 out · 60 thinking".
  def token_breakdown(tokens)
    {
      "in" => tokens.input,
      "out" => tokens.output,
      "cached" => tokens.cache_read,
      "thinking" => tokens.thinking
    }.filter_map { |label, count| "#{number_with_delimiter(count)} #{label}" if count.to_i.positive? }.join(" · ")
  end
end
