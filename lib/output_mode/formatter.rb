#==============================================================================
# Copyright 2021 William McCumstie
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

require 'tty-color'

module OutputMode
  class Formatter
    def self.constructor(&block)
      @constructor ||= block
    end

    def self.build(*objects, **opts)
      new(*objects, **opts).tap do |policy|
        next unless constructor
        policy.instance_exec(&constructor)
      end
    end

    def self.render(*objects, **opts)
      build(*objects, **opts).render
    end

    def initialize(*objects, verbose: nil, ascii: nil, interactive: nil, color: nil)
      @verbose = verbose
      @ascii = ascii
      @interactive = interactive
      @color = color

      # NOTE: This is intentionally not exposed on the base class
      #       It is up to the individual implementations to expose it
      @objects = objects
    end

    def callables
      @callables ||= Callables.new
    end

    def register(**config, &block)
      callables << Callable.new(**config) do |*args, **opts|
        raw = block.call(*args, **opts)
        case raw
        when TrueClass
          yes
        when FalseClass
          no
        when NilClass
          default
        else
          raw
        end
      end
    end

    def build_output
      raise NotImplementedError
    end

    def render
      build_output.render(*@objects)
    end

    def interactive?
      if @interactive.nil?
        $stdout.tty?
      else
        @interactive
      end
    end

    def color?
      if @color.nil? && (ascii? || !interactive?)
        false
      elsif @color.nil?
        TTY::Color.color?
      else
        @color
      end
    end

    def ascii?
      if @ascii.nil?
        !interactive?
      else
        @ascii
      end
    end

    def verbose?
      if @verbose.nil?
        !interactive?
      else
        @verbose
      end
    end

    def yes(value = nil)
      @yes = value unless value.nil?
      @yes ? @yes : (ascii? ? 'yes' : '✓')
    end

    def no(value = nil)
      @no = value unless value.nil?
      @no ? @no : (ascii? ? 'no' : '✕')
    end

    def default(value = nil)
      @default = value unless value.nil?
      @default ? @default : (interactive? ? '(none)' : '')
    end
  end
end
