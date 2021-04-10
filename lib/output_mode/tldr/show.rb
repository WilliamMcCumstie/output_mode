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

require 'tty-color'

module OutputMode
  module TLDR
    module Show
      include BuilderDSL

      # Register a field when displaying a model
      # @overload register_callable(header:, verbose: true)
      #   @param header: The human readable key to the field, uses the term 'header' for consistency
      #   @param verbose: Whether the field will be shown in the verbose output
      #   @param interactive: Whether the field will be show in the interactive output
      #   @param section: Define the grouping a callable belongs to. Ignored by default
      #   @param modes: Additional modes flags for the callable
      #   @yieldparam model The subject the column is describing, some sort of data model
      def register_callable(modes: {}, header:, verbose: nil, interactive: nil, section: :other, &b)
        modes = modes.map { |m| [m, true] }.to_h if modes.is_a? Array
        super(modes: modes.merge(verbose: verbose, interactive: interactive),
              header: header,
              section: section,
              &b)
      end
      alias_method :register_attribute, :register_callable

      # Creates an new +output+ from the verbosity flag. This method only uses
      # +$stdout+ as part of it's output class discovery logic. It does not
      # print to the io directly
      #
      # The +ascii+ flag disables the unicode formatting in interactive shells.
      # Non interactive shells use ASCII by default.
      #
      # The +verbose+ flag toggles the simplified and verbose outputs in the
      # interactive output. Non-interactive outputs are always verbose
      #
      # If +$stdout+ is an interactive shell (aka a TTY), then it will display using
      # {OutputMode::Outputs::Templated}. This is intended for human consumption
      # and will obey the provided +verbose+ flag.
      #
      # If +$stdout+ is non-interactive, then it will display using
      # {OutputMode::Outputs::Delimited} using tab delimiters. This is intended
      # for consumption by machines. This output ignores the provided +verbose+
      # flag as it is always verbose.
      #
      # The +template+ overrides the default erb template for the output
      #
      # An interative/ non-interactive output can be forced by setting the
      # +interactive+ flag to +true+/+false+ respectively
      def build_output(verbose: nil, ascii: nil, interactive: nil, template: nil, context: {})
        # Set the interactive and verbose flags if not provided
        interactive = $stdout.tty?  if interactive.nil?
        verbose =     !interactive  if verbose.nil?
        ascii =       !interactive  if ascii.nil?

        # Update the rendering context with the verbosity/interactive settings
        context = context.merge(interactive: interactive, verbose: verbose, ascii: ascii)

        callables = if verbose
          # Filter out columns that are explicitly not verbose
          output_callables.select { |o| o.verbose?(true) }
        else
          # Filter out columns that are explicitly verbose
          output_callables.reject(&:verbose?)
        end

        callables = if interactive
          # Filter out columns that are explicitly not interactive
          callables.select { |o| o.interactive?(true) }
        else
          # Filter out columns that are explicitly interactive
          callables.reject { |o| o.interactive? }
        end

        if interactive
          # Creates the human readable output
          opts =  if ascii
                    { yes: 'yes', no: 'no', colorize: false }
                  else
                    { yes: '✓', no: '✕', colorize: TTY::Color.color? }
                  end

          sections = callables.map { |o| o.config[:section] }

          Outputs::Templated.new(*callables,
                                 fields: callables.map { |c| c.config.fetch(:header, 'missing') },
                                 default: '(none)',
                                 sections: sections,
                                 template: template,
                                 context: context,
                                 **opts)
        else
          # Creates the machine readable output
          Outputs::Delimited.new(*callables, col_sep: "\t", yes: 'yes', no: 'no', default: nil,
                                 context: context)
        end
      end
    end
  end
end
