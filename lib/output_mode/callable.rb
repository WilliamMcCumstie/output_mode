#==============================================================================
# Copyright 2020 William McCumstie
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#==============================================================================

module OutputMode
  # Internal array like object that will convert procs to Callable
  class Callables < Array
    # @api private
    def initialize(callables = nil)
      case callables
      when Array
        super().tap do |all|
          callables.each { |c| all << c }
        end
      when nil
        super()
      else
        raise "Can not convert #{callables.class} into a #{self.class}"
      end
    end

    def <<(item)
      if item.is_a? Callable
        super
      elsif item.respond_to?(:call)
        super(Callable.new(&item))
      else
        raise Error, "#{item.class} is not callable"
      end
    end
  end

  class Callable
    # @!attribute [r] modes
    #   @return [Hash<Symbol => Boolean>] Returns the configured modes
    # @!attribute [r] callable
    #   @return [#call] Returns the underlining block
    # @!attribute [r] config
    #   @return [Hash] An arbitrary hash of key-value pairs
    attr_reader :modes, :callable, :config

    # Wraps a block/ callable object with mode query methods
    # @overload initialize(modes: {}, **config)
    #   @param [Hash<Symbol => Boolean>] modes: Provide the preconfigured modes
    #   @param **config An arbitrary hash to be stored on the object
    #   @yield Executed by the {#call} method
    #   @yieldparam *a The arguments provided to {#call}
    # @overload initialize(modes: []) { |*a| ... }
    #   @param [Array] modes: The preconfigured modes as an array, this will be converted to a hash
    def initialize(modes: {}, **config, &block)
      @callable = block
      @modes = if modes.is_a? Hash
                 modes.reject { |_, v| v.nil? }
                      .map { |k, v| [k, v ? true : false] }
                      .to_h
               else
                 modes.map { |k| [k, true] }.to_h
               end
      @config = config
    end

    # Handles the dynamic +<query>?+ and +<explicit-negation>!+ methods
    #
    # @return [Boolean] The result of the query or explicit-negation
    # @raise [NoMethodError] All other method calls
    def method_missing(s, *args, &b)
      mode = s[0..-2].to_sym
      case method_char(s)
      when '?'
        ifnone = (args.length > 0 ? args.first : false)
        modes.fetch(mode, ifnone)
      when '!'
        send(:"#{mode}?", true)
      else
        super
      end
    end

    # @!method mode?(ifnone = false)
    #   This is a dynamic method for check if an arbitrary +mode+ has been set. It will
    #   return the associated value if the +mode+ has been defined in {#modes}.
    #
    #   Otherwise it will return the +ifnone+ value
    #   @return [Boolean] the associated value if +mode+ has been defined
    #   @return otherwise return the +ifnone+ value
    #
    # @!method mode!
    #   Older syntax that returns +true+ if the +mode+ has not been defined. Otherwise
    #   the same as {#mode?}
    #
    #   @return [Boolean]
    #   @deprecated Please use the newer +mode?(true)+ syntax

    # Responds +true+ for valid dynamic methods
    # @param [Symbol] s The method to be tested
    # @return [Boolean] The truthiness of the underlining call to {#method_char}
    def respond_to_missing?(s, *_)
      method_char(s) ? true : false
    end

    # Determines the "type" associated with a dynamic method
    # @overload method_char(bang!)
    #   @param bang! A symbol/string ending with !
    #   @return ['!']
    # @overload method_char(question?)
    #   @param question? A symbol/string ending with ?
    #   @return ['?']
    # @overload method_char(other)
    #   @param other Any other symbol/string
    #   @return [Nil]
    def method_char(s)
      char = s[-1]
      ['?', '!'].include?(char) ? char : nil
    end

    # Calls the underlining block
    # @param *a The arguments to be provided to {#callable}
    # @return The results from the block
    def call(*a)
      callable.call(*a)
    end
  end
end

