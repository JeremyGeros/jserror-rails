require 'sprockets'
require 'tilt'

module JserrorRails
  class JserrorTemplate < Tilt::Template

    def self.default_mime_type
      'application/javascript'
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      data_copy = data
      scanning_data = data
      functions = []
      capture = true
      while capture
        function = (/(^.*= function.*$)/).match(scanning_data)
        if function 
          if function.to_s.count('{') != function.to_s.count('}')
            old_lines = []
            new_code_lines = []

            scanning_data = function.post_match
            method_line = function.captures.first
          
            tabs = method_line.partition(method_line.strip[0]).first
            name = method_line.match(/(.*) = function/).captures.first.strip
          
            arguments = method_line.gsub(tabs, '').gsub(name, '').gsub(/\s*=\s*function\s*\(/, '').gsub(/\)\s*{.*$/, '').strip.split(', ').map {|a| "{#{a}: #{a}}"}

            new_code_lines << method_line
            old_lines << method_line
          
            new_code_lines << "\n#{tabs}\ttry {"

            bracket_count = 1 #start scanning until we find the ending bracket
            scanning_data.each_line do |line|
              line.chars do |char|
                bracket_count += 1 if char == '{'
                bracket_count -= 1 if char == '}'
              end
              new_code_lines << "\t" + line
              old_lines << line
              break if bracket_count <= 0
            end
          
            new_code_lines.pop #pop of the last }; to add catch block before closing bracket in function

            console_line = "javascript_error({name: '#{name.gsub('\'', '"')}',  
                                        error_message: e.message, 
                                        error_name: e.name, 
                                        code_block: '#{old_lines.join('').gsub("\n", '[::n::]').gsub('\'', '')}', 
                                        arguments: [#{arguments.join(', ')}]
                            });"
          
            new_code_lines << "#{tabs}\t} catch (e) { \n#{tabs}\t\t#{console_line}\n#{tabs}\t}\n"
            new_code_lines << "#{tabs}};\n"
            functions << {:replace => old_lines.join(''), :new => new_code_lines.join('')}
          else
            scanning_data = function.post_match
          end
        else
          capture = false
        end
      end
      
      scanning_data = data_copy.clone
      capture = true
      while capture
        function = (/(.*\(.+function\(.*\).*\{.*$)/).match(scanning_data)
        if function
          if function.to_s.match(/setTimeout/).nil?
            old_lines = []
            new_code_lines = []

            scanning_data = function.post_match
            method_line = function.captures.first
          
            tabs = method_line.partition(method_line.strip[0]).first
          
            name = method_line
            arguments = (/.*\(.+function\((.*)\).*\{.*$/).match(method_line).captures.first.split(', ').map {|a| "{#{a}: #{a}}"}

            new_code_lines << method_line
            old_lines << method_line
          
            new_code_lines << "\n#{tabs}\ttry {"

            bracket_count = 1 #start scanning until we find the ending bracket
            scanning_data.each_line do |line|
              line.chars do |char|
                bracket_count += 1 if char == '{'
                bracket_count -= 1 if char == '}'
              end
              new_code_lines << "\t" + line
              old_lines << line
              break if bracket_count <= 0
            end
          
            new_code_lines.pop #pop of the last }; to add catch block before closing bracket in function

            console_line = "javascript_error({name: '#{name.gsub('\'', '"')}',  
                                        error_message: e.message, 
                                        error_name: e.name, 
                                        code_block: '#{old_lines.join('').gsub("\n", '[::n::]').gsub('\'', '')}', 
                                        arguments: [#{arguments.join(', ')}]
                            });"
          
            new_code_lines << "#{tabs}\t} catch (e) { \n#{tabs}\t\t#{console_line}\n#{tabs}\t}\n"
            new_code_lines << "#{tabs}});\n"
            functions << {:replace => old_lines.join(''), :new => new_code_lines.join('')}
          else
            scanning_data = function.post_match
          end
        else
          capture = false
        end
      end
      

      functions.each do |s|
        data_copy.gsub!(s[:replace], s[:new])
      end
      
      output = "try {"
      output << data_copy
      output << "} catch (e) { javascript_error({name: 'unfound javascript error', error_message: e.message, error_name: e.name, code_block: '#{scope.logical_path.to_s}', arguments: []}); }"
      output
    end
  end
end
