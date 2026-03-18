module ApplicationHelper
  def summarize_event_for_councillor(event, councillor)
    case event.eventable_type.downcase
    when "election"
      "Elected to the council"
    when "changeofaffiliation"
      "Changed party affiliation from #{link_to event.eventable.outgoing_party.name, event.eventable.outgoing_party} to #{link_to event.eventable.incoming_party.name, event.eventable.incoming_party}"
    when "cooption"
      outgoing = event.eventable.outgoing_seat&.councillor
      incoming = event.eventable.incoming_seat&.councillor
      # If incoming data is missing but we're on the incoming councillor's page, use them
      incoming ||= councillor if outgoing != councillor

      if outgoing && incoming
        incoming_display = incoming == councillor ? incoming.full_name : link_to(incoming.full_name, incoming)
        "#{link_to outgoing.full_name, outgoing} resigned from the council and was replaced by #{incoming_display}"
      elsif outgoing
        "#{link_to outgoing.full_name, outgoing} resigned from the council"
      elsif incoming
        "Co-opted to the council (replacing a vacant seat)"
      else
        "Co-option event (data incomplete)"
      end
    else
      raise "Must implement summary for #{event.eventable_type}"
    end
  end

  def status_from_vote_result(result)
    case result
    when "pass" then "for"
    when "fail" then "against"
    when "error" then "abstain"
    end
  end

  def indefinitly_article(word)
    %w[a e i o u].include?(word[0].downcase) ? "an #{word}" : "a #{word}"
  end
end
