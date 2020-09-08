require "./timer.cr"

# TODO: Write documentation for `Raft`
module Raft
  VERSION = "0.1.0"

  class Node
    def initialize(id : Int32)
      @commit_index = 0
      @last_applied = 0
      # TODO replace with UUID
      @id = id
      @peers = [] of Node

      # TODO load these from some persistence layer
      @current_term = 0
      @voted_for = nil
      @log = [] of String
    end

    def peers=(peers)
      @peers = peers
    end

    def id()
      @id
    end

    def run_election_timer()
      timeout_duration = Time::Span.new(nanoseconds: (150 + Random.rand(150)) * 1000)
      election_timer = Timer::Timer.new(timeout_duration)
      select
      when election_timer.channel.receive
        start_election()  
      end
    end

    def start_election()
      # TODO implement me
      puts "Election started on node #{@id}"
      @voted_for = @id
      votes_received = 1

      @peers.each do |peer|
        puts "Sending vote request to node #{peer.id}"
        current_term, vote_granted = peer.request_vote(@current_term, @id)
        if vote_granted
          puts "Node #{peer.id} granted vote to #{@id}"
          votes_received += 1
        else
          puts "Vote failed for node #{@id}"
          @current_term = current_term
          @voted_for = nil
        end
      end

      # TODO remove this conditional
      if @voted_for.nil?
        spawn run_election_timer()
      end
    end

    def request_vote(term : Int32, candidate_id : Int32)
      puts "Node #{@id} received vote request from node #{candidate_id} with term #{term}"
      if (@voted_for.nil? || @voted_for == candidate_id) && term >= @current_term
        puts "Node #{@id} voting for node #{candidate_id}"
        @voted_for = candidate_id
        return { @current_term, true }
      else
        puts "Node #{@id} rejecting vote for #{candidate_id}"
        return { @current_term, false }
      end
    end


  end
end

