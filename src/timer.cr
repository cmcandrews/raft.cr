module Timer
    class Timer
        property start
        property duration
        property channel

        getter channel : Channel(Nil)

        def initialize(duration : Time::Span)
            @duration = duration
            @channel = Channel(Nil).new
            @start = Time.utc

            spawn do
                until Time.utc >= @start + @duration
                    sleep 1.millisecond
                end
                @channel.send(nil)
            end
            Fiber.yield
        end
    end
end
