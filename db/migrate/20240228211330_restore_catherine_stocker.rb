class RestoreCatherineStocker < ActiveRecord::Migration[6.1]
  def change
    date = Date.new(2023, 9, 1)  # The date Karl Stanley steps down
    session = CouncilSession.current_on(date).take

    # Assuming 'find_by_councillor_name' and 'find_or_create_by' are defined and work as expected
    CoOption.create(
      occurred_on: date,
      outgoing_seat: session.seats.find_by_councillor_name("Karl Stanley"),
      incoming_councillor: Councillor.find_or_create_by(full_name: "Catherine Stocker", dcc_id: "837"),  # Replace 'your_dcc_id_here' with Catherine's actual dcc_id
      incoming_party: Party.find_by(slug: "social-democrats")  # Assuming Catherine returns to the same party
    )
  end
end
