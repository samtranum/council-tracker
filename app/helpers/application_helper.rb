module ApplicationHelper
  def summarize_event_for_councillor(event, councillor)
    case event.eventable_type.downcase
    when "election"
      "Elected with #{event.related_seat_ids.count - 1} other councillors"
    when "changeofaffiliation"
      "Changed party affiliation from #{link_to event.eventable.outgoing_party.name, event.eventable.outgoing_party} to #{link_to event.eventable.incoming_party.name, event.eventable.incoming_party}"
    when "cooption"
      outgoing_seat = event.eventable.outgoing_seat
      incoming_seat = event.eventable.incoming_seat
      
      if outgoing_seat&.councillor && incoming_seat&.councillor
        "#{link_to outgoing_seat.councillor.full_name, outgoing_seat.councillor} resigned from the council and was replaced by #{link_to incoming_seat.councillor.full_name, incoming_seat.councillor}"
      elsif outgoing_seat&.councillor
        "#{link_to outgoing_seat.councillor.full_name, outgoing_seat.councillor} resigned from the council"
      elsif incoming_seat&.councillor
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
