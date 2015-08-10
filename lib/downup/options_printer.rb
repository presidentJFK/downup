require_relative "colors"

module Downup
  class OptionsPrinter
    using Colors

    def initialize(options:,
                   selected_position:,
                   title: nil,
                   default_color: :brown,
                   selected_color: :magenta,
                   selector: "‣",
                   stdin: $stdout,
                   stdout: $stdout,
                   header_proc: Proc.new {})

      @options           = options
      @title             = title
      @default_color     = default_color
      @selected_position = selected_position
      @selected_color    = selected_color
      @selector          = selector
      @header_proc       = header_proc
      @stdin             = stdin
      @stdout            = stdout
      @colonel           = Kernel
    end

    def print_options
      case options
      when Array then print_array_options
      when Hash
        if options_has_value_and_display?
          print_complex_hash_options
        else
          print_simple_hash_options
        end
      end
    end

    private

    attr_reader :options,
                :title,
                :selected_position,
                :header_proc,
                :selected_color,
                :selector,
                :default_color,
                :stdin,
                :stdout,
                :colonel

    def print_complex_hash_options
      options.each_with_index do |option_array, index|
        key = option_array.first
        value_hash = option_array.last
        if index == selected_position
          stdout.puts "(#{eval("selector.#{selected_color}")}) " +
            eval("value_hash.fetch('display').#{selected_color}")
        else
          stdout.print "(#{eval("key.#{default_color}")}) "
          stdout.print "#{eval("value_hash.fetch('display').#{default_color}")}\n"
        end
      end
    end

    def print_simple_hash_options
      options.each_with_index do |option_array, index|
        if index == selected_position
          stdout.puts "(#{eval("selector.#{selected_color}")}) " +
            eval("option_array.last.#{selected_color}")
        else
          stdout.print "(#{eval("option_array.first.#{default_color}")}) "
          stdout.print "#{eval("option_array.last.#{default_color}")}\n"
        end
      end
    end

    def print_array_options
      options.each_with_index do |option, index|
        stdout.puts colorize_option(option, index)
      end
    end

    def colorize_option(option, index)
      if index == selected_position
        eval("option.#{selected_color}")
      else
        eval("option.#{default_color}")
      end
    end

    # Duplicated in Base, maybe move onto Hash and String with contrainsts
    def options_has_value_and_display?
      options.values.all? { |option|
        option.is_a?(Hash) && option.has_key?("value")
      } && options.values.all? { |option|
        option.is_a?(Hash) && option.has_key?("display")
      }
    end
  end
end
