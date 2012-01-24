module AlertTweeter
  class Worker
    deferred_event :start, :stop, :connection_failed

    def initialize(connection)
      @connection = connection
      @channel = @exchange = @queue = nil
    end

    def start!(&blk)
      on_start(&blk)
      return on_start if @started

      @started = true

      AMQP::Channel.new(@connection) do |chan,_|
        @channel = chan
        @channel.direct(EXCHANGE_NAME, :auto_delete => false) do |exch|
          @exchange = exch

          @channel.queue(WORKER_QUEUE_NAME, :auto_delete => false, :durable => true) do |q,_|
            @queue = q
            queue.bind(@exchange, :routing_key => ROUTING_KEY) do
              on_start.succeed
            end
          end
        end
      end
    end
  end
end

