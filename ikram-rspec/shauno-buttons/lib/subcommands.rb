module Subcommands 
    class NoPermissionError < StandardError
        def message
            "Please check your permissions and try again"
        end
    end

    def self.list_buttons()
        return $client.query(
            "SELECT developer_pairings.button_id, reason, name FROM reason_pairings 
            JOIN developer_pairings ON reason_pairings.button_id=developer_pairings.button_id 
            JOIN reasons ON reason_pairings.reason_id=reasons.id 
            JOIN developers ON developer_pairings.developer_id=developers.id;")
    end

    def self.add_event(button_id, timestamp, developer, reason) 
        query_text = "INSERT INTO events (button_id, timestamp, developers_id, reason_id) VALUES (?, ?, ?, ?);"
        statement = $client.prepare(query_text)
        statement.execute(button_id, timestamp, developer, reason)
    end

    def self.is_admin(developer_id)
        query_text = "SELECT is_admin FROM developers WHERE id=?"
        statement = $client.prepare(query_text)
        result = statement.execute(developer_id).first

        if result["is_admin"] == 1
            return true
        else
            raise NoPermissionError
            # return false
        end
    end

end