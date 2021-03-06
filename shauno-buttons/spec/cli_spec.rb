require 'optimist'
require 'mysql2'
require 'pp'

require 'cli'
require 'subcommands'

describe Subcommands do
    before(:all) do

        result = $client.query(File.read("./data/truncate.sql"))
        while $client.next_result
            result = $client.store_result
        end

        result = $client.query(File.read("./data/setup.sql"))

        while $client.next_result #this checks if theres another result left to handle
            result = $client.store_result
        end
    end
    
    context 'list_buttons' do
        it "returns the correct number of buttons" do
            expected_num = 6

            result = Subcommands::list_buttons

            expect(result.size).to eq(expected_num)
        end

        it "lists the correct reason with the buttons" do
            result = Subcommands::list_buttons

            correct_reason = "CI is broken"

            expect(result.first["reason"]).to eq(correct_reason)
        end

        it "lists the correct developer with the buttons" do
            result = Subcommands::list_buttons
            correct_name = "Ikram Saedi"

            expect(result.first["name"]).to eq(correct_name)
        end
    end

    context "add_event" do
        let(:button_id) { 2 }
        let(:timestamp) { "2021-3-2 06:24:49" }
        let(:developer_id) { 1 }
        let(:reason_id) { 3 }

        it "successfully adds event when given valid information" do
            Subcommands::add_event(button_id, timestamp, developer_id, reason_id)

            result = $client.query("SELECT button_id, DATE_FORMAT(timestamp, '%Y-%c-%e %H:%i:%s') AS timestamp, developers_id, reason_id, to_ignore FROM events WHERE button_id=#{button_id} AND timestamp='#{timestamp}';")

            result = result.first

            expected = {"button_id" => button_id, "timestamp" => timestamp, "developers_id" => developer_id, "reason_id" => reason_id, "to_ignore" => 0}

            expect(result).to eq(expected)
        end

        it "does not insert event into table when timestamp is missing" do
            timestamp = nil

            expect {Subcommands::add_event(button_id, timestamp, developer_id, reason_id)}.to raise_error(Mysql2::Error)
        end

        it "does not insert event into table when button is missing" do
            button_id = nil

            expect {Subcommands::add_event(button_id, timestamp, developer_id, reason_id)}.to raise_error(Mysql2::Error)
        end

        it "does not insert event into table when developer_id is missing" do
            developer_id = nil

            expect {Subcommands::add_event(button_id, timestamp, developer_id, reason_id)}.to raise_error(Mysql2::Error)
        end

        it "does not insert event into table when reason_id is missing" do
            reason_id = nil

            expect {Subcommands::add_event(button_id, timestamp, developer_id, reason_id)}.to raise_error(Mysql2::Error)
        end
    end
    
    context "checking if a developer is an admin" do
        it "succeeds if the developer is an admin" do
            expect(Subcommands::is_admin!(3)).to be true
        end

        it "errors if the developer is not an admin" do
            expect {Subcommands::is_admin!(2)}.to raise_error(Subcommands::NoPermissionError)
        end

        it "errors if the developer_id does not exist in the table" do
            expect {Subcommands::is_admin!(6)}.to raise_error(Subcommands::NoPermissionError)
        end
    end

    context "invalidate event" do
        it "succeeds when supplied with an admin user" do
            button_id = 6
            timestamp = '2021-08-03 05:39:47'
            developer_id = 3

            Subcommands::invalidate_event(developer_id, button_id, timestamp)

            result = $client.query("SELECT to_ignore FROM events WHERE button_id=#{button_id} AND timestamp='#{timestamp}'")

            expect(result.first).to eq({"to_ignore" => 1})
        end
        
        it "raises a custom error when the user is not a admin" do
            button_id = 4
            timestamp = "2021-6-12 03:22:43"
            developer_id = 2

            expect {Subcommands::invalidate_event(developer_id, button_id, timestamp)}.to raise_error(Subcommands::NoPermissionError)
        end
    end

    context "add button" do
        let(:uuid) { "fa22866c-f8af-11eb-9a03-0242ac130003" }
        let(:reason_id) { 3 }
        let(:developer_id) { 1 }

        it "adds button successfully" do
            Subcommands::add_button(uuid, reason_id, developer_id)

            statement = $client.prepare("SELECT button_id, uuid FROM buttons WHERE uuid=?")
            result = statement.execute(uuid)
            result = result.first

            expect(result["uuid"]).to eq(uuid)

            db_button_id = result["button_id"]

            statement = $client.prepare("SELECT button_id, reason_id FROM reason_pairings WHERE button_id=?")
            result = statement.execute(db_button_id)
            result = result.first

            expect(result["button_id"]).to eq(db_button_id)
            expect(result["reason_id"]).to eq(reason_id)

            statement = $client.prepare("SELECT button_id, developer_id FROM developer_pairings WHERE button_id=?")
            result = statement.execute(db_button_id)
            result = result.first

            expect(result["button_id"]).to eq(db_button_id)
            expect(result["developer_id"]).to eq(developer_id)
            
        end

        it "throws an error if the uuid is already in the table" do #this requires adding a constraint
            uuid = "467fa190-d806-4d45-9eda-08e322d6fccf"

            expect {Subcommands::add_button(uuid, reason_id, developer_id)}.to raise_error(Mysql2::Error)
        end

        it "does not insert into table when uuid is missing" do
            uuid = nil

            expect {Subcommands::add_button(uuid, reason_id, developer_id)}.to raise_error(Mysql2::Error)
        end

        it "does not insert into table when reason_id is missing" do
            reason_id = nil

            expect {Subcommands::add_button(uuid, reason_id, developer_id)}.to raise_error(Mysql2::Error)
        end

        it "does not insert into table when developer_id is missing" do
            developer_id = nil

            expect {Subcommands::add_button(uuid, reason_id, developer_id)}.to raise_error(Mysql2::Error)
        end
    end

    context "invalidate button" do
        let(:button_id) { 1 }
        let(:developer_id) { 3 }

        it "invalidates button successfully" do
            Subcommands::invalidate_button(developer_id, button_id)

            statement = $client.prepare("SELECT is_active FROM buttons WHERE button_id=?;")
            result = statement.execute(button_id)
            result = result.first

            expect(result["is_active"]).to eq(0) 

            statement = $client.prepare("SELECT CURRENT FROM reason_pairings WHERE button_id=?;")
            result = statement.execute(button_id)
            result = result.first

            expect(result["CURRENT"]).to eq(0)

            statement = $client.prepare("SELECT CURRENT FROM developer_pairings WHERE button_id=?;")
            result = statement.execute(button_id)
            result = result.first

            expect(result["CURRENT"]).to eq(0)
        end

        it "errors when the developer is not an admin" do
            developer_id = 2
            expect {Subcommands::invalidate_button(developer_id, button_id)}.to raise_error(Subcommands::NoPermissionError)
        end
    
        it "errors when button id is missing" do
            button_id = nil

            expect {Subcommands::invalidate_button(developer_id, button_id)}.to raise_error(Subcommands::InvalidDataError)
        end

        it "errors when developer id is missing" do
            developer_id = nil

            expect {Subcommands::invalidate_button(developer_id, button_id)}.to raise_error(Subcommands::NoPermissionError)
        end
    end

    context "reassign button" do
        let(:button_id) { 2 }
        let(:new_reason_id) { 2 }
        let(:new_developer_id) {2}

        it "successfully assigns a new reason" do
            new_developer_id = nil

            Subcommands::reassign_button(button_id, new_reason_id, new_developer_id)

            statement = $client.prepare("SELECT button_id, reason_id FROM reason_pairings WHERE button_id=? AND reason_id=?;")
            result = statement.execute(button_id, new_reason_id).first

            expect(result["button_id"]).to eq(button_id)
            expect(result["reason_id"]).to eq(new_reason_id)
        end
        
        it "successfully assigns a new developer" do
            new_reason_id = nil

            Subcommands::reassign_button(button_id, new_reason_id, new_developer_id)

            statement = $client.prepare("SELECT button_id, developer_id FROM developer_pairings WHERE button_id=? AND developer_id=?;")
            result = statement.execute(button_id, new_developer_id).first

            expect(result["button_id"]).to eq(button_id)
            expect(result["developer_id"]).to eq (new_developer_id)

        end
        
        it "successfully assigns both a new developer and reason" do
            Subcommands::reassign_button(button_id, new_reason_id, new_developer_id)

            statement = $client.prepare("SELECT button_id, reason_id FROM reason_pairings WHERE button_id=? AND reason_id=?;")
            result = statement.execute(button_id, new_reason_id).first

            expect(result["button_id"]).to eq(button_id)
            expect(result["reason_id"]).to eq(new_reason_id)

            statement = $client.prepare("SELECT button_id, developer_id FROM developer_pairings WHERE button_id=? AND developer_id=?;")
            result = statement.execute(button_id, new_developer_id).first

            expect(result["developer_id"]).to eq (new_developer_id)
        end

        it "throws errors when button provided is inactive" do
            button_id = 1 #inactive button
            expect {Subcommands::reassign_button(button_id, new_reason_id, new_developer_id)}.to raise_error(Subcommands::InactiveButtonError)
        end

        it "throws error when neither reason id or developer id is given" do
            new_developer_id = nil
            new_reason_id = nil

            expect {Subcommands::reassign_button(button_id, new_reason_id, new_developer_id)}.to raise_error(Subcommands::InvalidDataError)
        end
    end

    context "list timeblocks" do
        let(:result) { Subcommands::list_timeblocks }
        it "returns the correct number of timeblocks" do
            expected_num = 8

            # result = Subcommands::list_timeblocks
            
            expect(result.size).to eq(expected_num)
        end

        it "returns the correct developer name" do
            expected_name = "Ikram Saedi"

            expect(result.first["developer"]).to eq(expected_name)
        end

        it "returns the correct reason" do
            expected_reason = "Developer sad"

            expect(result.first["reason"]).to eq(expected_reason)
        end

        it "returns the correct starting timestamp" do
            expected_timestamp = "2021-8-3 00:36:30"

            expect(result.first["start"]).to eq(expected_timestamp)
        end

        it "returns the correct ending timestamp" do
            expected_timestamp = "2021-8-3 20:52:22"
            
            expect(result.first["end"]).to eq(expected_timestamp)
        end
    end

    context "list_timeblock_events" do
        let(:result) { Subcommands::list_timeblock_events(1) } # list all the events from timeblock 1

        it "successfully lists the correct number of events in the timeblock" do
            expected_num = 3

            expect(result.size).to eq(expected_num)
        end

        it "returns the correct information for the first event" do
            expected_button = 1
            expected_timestamp = "2021-8-3 00:36:30"

            expect(result.first["button_id"]).to eq(expected_button)
            expect(result.first["timestamp"]).to eq(expected_timestamp)
        end

        it "errors when given a timeblock that doesn't exist" do
            expect {Subcommands::list_timeblock_events(10)}.to raise_error(Subcommands::InvalidDataError)
        end

        it "errors when nil timeblock is given" do
            expect {Subcommands::list_timeblock_events(nil)}.to raise_error(Subcommands::InvalidDataError)
        end
    end

    context "reassign_event" do 
    let(:timestamp) { "2021-08-03 00:36:30" }
    let(:button_id) { 1 }
    let(:timeblock_id) { 9 }
        it "successfully reassigns event to new timeblock" do
            Subcommands::reassign_event(button_id, timestamp)
            result = $client.query("SELECT developer_id, reason_id FROM timeblocks WHERE timeblock_id=9;").first
            expect(result["developer_id"]).to eq(1)
            expect(result["reason_id"]).to eq(2)

            result = $client.query("SELECT timeblock_id FROM timeblock_mapping WHERE button_id=#{button_id} AND timestamp='#{timestamp}';").first
            expect(result["timeblock_id"]).to eq(9)
        end

        it "successfully reassigns event to existing timeblock" do
            button_id = 2
            timestamp = "2021-08-03 20:52:22"

            Subcommands::reassign_event(button_id, timestamp, timeblock_id)
            result = $client.query("SELECT developer_id, reason_id FROM timeblocks WHERE timeblock_id=9;").first
            expect(result["developer_id"]).to eq(1)
            expect(result["reason_id"]).to eq(2)

            result = $client.query("SELECT timeblock_id FROM timeblock_mapping WHERE button_id=#{button_id} AND timestamp='#{timestamp}';").first
            expect(result["timeblock_id"]).to eq(9)
        end

        it "errors when reassigning event that does not exist" do
            timestamp = "2021-08-06 00:26:10"
            
            expect {Subcommands::reassign_event(button_id, timestamp)}.to raise_error(Subcommands::InvalidDataError)
            expect {Subcommands::reassign_event(button_id, timestamp, timeblock_id)}.to raise_error(Subcommands::InvalidDataError)
        end

        it "errors when timeblock developer and reason and event developer and reason do not match" do
            timeblock_id = 4

            expect {Subcommands::reassign_event(button_id, timestamp, timeblock_id)}.to raise_error(Subcommands::InvalidDataError)
        end

        it "errors when the timeblock passed in does not exist" do
            timeblock_id = 25
            expect {Subcommands::reassign_event(button_id, timestamp, timeblock_id)}.to raise_error(Subcommands::InvalidDataError)
        end
    end
    
    context "clean_timeblocks" do
        before(:all) do
            Subcommands::reassign_event(1, "2021-08-03 00:36:30", 1)
            Subcommands::reassign_event(2, "2021-08-03 20:52:22", 1)

            Subcommands::clean_timeblocks
        end

        it "successfully deletes rows in the timeblocks table that are not associated with any events" do
            result = $client.query("SELECT * FROM timeblocks WHERE timeblock_id=9;").first

            expect(result).to be_nil
        end

        it "does not delete rows in the timeblocks table that are associated with events" do 
            result = $client.query("SELECT COUNT(*) FROM timeblocks;").first

            expect(result["COUNT(*)"]).to eq(8)
        end
    end
end