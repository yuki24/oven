# frozen-string-literal: true
module Oven
  module Patches
    module StringExt
      refine Symbol do
        def underscore
          to_s.underscore
        end

        def namespace
          to_s.namespace.to_sym
        end

        def deconstantize
          to_s.deconstantize
        end
      end

      refine String do
        def underscore
          return self unless self =~ /[A-Z-]|::/
          word = gsub('::', '/')
          word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{/(?=a)b/})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.tr!("-", "_")
          word.downcase!
          word
        end

        def namespace
          self[0, rindex('/') || -1]
        end

        def deconstantize
          self[0, rindex('::') || 0]
        end
      end
    end
  end
end
