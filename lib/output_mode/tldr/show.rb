#==============================================================================
# Refer to LICENSE.txt for licensing terms
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
      #   @yieldparam model The subject the column is describing, some sort of data model
      def register_callable(header:, verbose: nil, &b)
        super(modes: { verbose: verbose }, header: header, &b)
      end
      alias_method :register_attribute, :register_callable

      # Creates an new +output+ from the verbosity flag. This method only uses
      # +$stdout+ as part of it's output class discovery logic. It does not
      # print to the io directly
      #
      # If +$stdout+ is an interactive shell (aka a TTY), then it will display using
      # {OutputMode::Outputs::Templated}. This is intended for human consumption
      # and will obey the provided +verbose+ flag.
      #
      # If +$stdout+ is non-interactive, then it will display using
      # {OutputMode::Outputs::Delimited} using tab delimiters. This is intended
      # for consumption by machines. This output ignores the provided +verbose+
      # flag as it is always verbose.
      def build_output(verbose: false)
        callables = if verbose || !$stdout.tty?
          # Filter out columns that are explicitly not verbose
          output_callables.select(&:verbose!)
        else
          # Filter out columns that are explicitly verbose
          output_callables.reject(&:verbose?)
        end

        if $stdout.tty?
          # Creates the human readable output
          Outputs::Templated.new(*callables,
                                 fields: callables.map { |c| c.config.fetch(:header, 'missing') },
                                 colorize: TTY::Color.color?,
                                 default: '(none)',
                                 yes: '✓', no: '✕')
        else
          # Creates the machine readable output
          Outputs::Delimited.new(*callables, col_sep: "\t", yes: 'y', no: 'n', default: '')
        end
      end
    end
  end
end
