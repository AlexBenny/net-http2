module NetHttp2

  class Stream

    def initialize(options={})
      @h2_stream = options[:h2_stream]
      @uri       = options[:uri]
      @headers   = {}
      @data      = ''
      @completed = false
      @block     = nil

      @h2_stream.on(:headers) do |hs|
        hs.each { |k, v| @headers[k] = v }
      end

      @h2_stream.on(:data) { |d| @data << d }
      @h2_stream.on(:close) { @completed = true }
    end

    def call_with(request)
      headers = request.headers
      body    = request.body

      if body
        @h2_stream.headers(headers, end_stream: false)
        @h2_stream.data(body, end_stream: true)
      else
        @h2_stream.headers(headers, end_stream: true)
      end

      respond(request.timeout)
    end

    private

    def respond(timeout)
      wait(timeout)

      if @completed
        NetHttp2::Response.new(
          headers: @headers,
          body:    @data
        )
      else
        nil
      end
    end

    def wait(timeout)
      cutoff_time = Time.now + timeout

      while !@completed && Time.now < cutoff_time
        sleep 0.1
      end
    end
  end
end
