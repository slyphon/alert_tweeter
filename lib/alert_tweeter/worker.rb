module AlertTweeter
  module Worker
    class IncomingHandler
      deferred_event :start, :stop, :connection_failed

      def initialize(connection)
        @connection = connection
        @channel = @exchange = @queue = nil
        @started = @stopped = false
        @on_message_block = nil
      end

      def start!(&blk)
        raise "You must register a message handler before start!" unless @on_message_block

        on_start(&blk)
        return on_start if @started
        @started = true

        AMQP::Channel.new(@connection) do |chan,_|
          @channel = chan
          @channel.direct('') do |exch|
            @exchange = exch

            @channel.queue(WORKER_QUEUE_NAME, :auto_delete => false, :durable => true) do |q,_|
              @queue = q
              @queue.bind(@exchange, :routing_key => ROUTING_KEY) do
                @queue.subscribe(&@on_message_block)
                on_start.succeed
              end
            end
          end
        end
      end

      def stop!(&blk)
        on_stop(&blk)
        return on_stop if @stopped
        @stopped = true

        if @channel
          @channel.close do
            on_stop.succeed
          end
        else
          on_stop.succeed
        end

        on_stop
      end

      def on_message(&block)
        @on_message_block = block
      end
    end

    class Tweeter
      attr_reader :opts

      def initialize(opts)
        @opts = opts
      end



      private
        def method_missing(name, *a, &b)
          namesym = name.to_sym
          if val = opts[namesym]
            return val
          else
            super
          end
        end
    end
  end
end

