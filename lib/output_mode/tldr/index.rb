#==============================================================================
# Refer to LICENSE.txt for licensing terms
#==============================================================================

module OutputMode
  module TLDR
    module Index
      include BuilderDSL

      # Register a new column in the Index table
      # @overload register_callable(header:, verbose: true)
      #   @param header: The column's header field when displaying to humans
      #   @param verbose: Whether the column will be shown in the verbose output
      #   @yieldparam model The subject the column is describing, some sort of data model
      def register_callable(header:, verbose: nil, &b)
        super(modes: { verbose: verbose }, header: header, &b)
      end
      alias_method :register_column, :register_callable

      # Creates an new +output+ from the verbosity flag. This method only uses
      # +$stdout+ as part of it's output class discovery logic. It does not
      # print to the output directly
      #
      # The +ascii+ flag disables the unicode formatting in interactive shells
      #
      # If +$stdout+ is an interactive shell (aka a TTY), then it will display using
      # {OutputMode::Outputs::Tabulated}. This is intended for human consumption
      # and will obey the provided +verbose+ flag.
      #
      # If +$stdout+ is non-interactive, then it will display using
      # {OutputMode::Outputs::Delimited} using tab delimiters. This is intended
      # for consumption by machines. This output ignores the provided +verbose+
      # flag as it is always verbose.
      def build_output(verbose: false, ascii: false)
        callables = if verbose || !$stdout.tty?
          # Filter out columns that are explicitly not verbose
          output_callables.select(&:verbose!)
        else
          # Filter out columns that are explicitly verbose
          output_callables.reject(&:verbose?)
        end

        if $stdout.tty?
          opts = if ascii
                   { yes: 'y', no: 'n', renderer: :ascii }
                 else
                   { yes: '✓', no: '✕', renderer: :unicode }
                  end

          # Creates the human readable output
          Outputs::Tabulated.new(*callables,
                                 header: callables.map { |c| c.config.fetch(:header, 'missing') },
                                 renderer: :unicode,
                                 padding: [0,1],
                                 default: '(none)',
                                 **opts
                                 )
        else
          # Creates the machine readable output
          Outputs::Delimited.new(*callables, col_sep: "\t", yes: 'y', no: 'n', default: '')
        end
      end
    end
  end
end
