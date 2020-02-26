# frozen_string_literal: true

def sayonara(&block)
  new_method = nil
  args = nil

  try = lambda(nm, *a) do
    new_method = nm
    args = a
  end

  begin
    return block.call(try)
  rescue Error, Exception => e
    if new_method.nil?
      raise e
    else
      # if the user passed in a method to try, call that, printing the exception, instead of crashing
      puts 'exception from prior byebugger crash statement: '
      pp e
      byebug # or pry, etc
      return new_method.call(*args)
    end
  end
end