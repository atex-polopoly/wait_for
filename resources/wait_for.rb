# The code to test with, should return truthy if successful, falsy otherwise
property :block, Proc, required: true
# The max time in seconds to test for before raising an exception
property :max_time, [Float, Integer], default: 180
# How long to wait in seconds before tests
property :interval, [Float, Integer], default: 5
# How long to let the test run before declaring it a failure, default is forever
property :timeout, [Float, Integer]

resource_name :wait_for

def wait_timeout(thr, max)
  wait = Time.now
  until Time.now - wait >= max
    if thr.status == false
      return true
    elsif thr.status.nil?
      return false
    end
    sleep 0.1
  end
  return false
end

action :run do
  start = Time.now
  out = false
  until Time.now - start >= new_resource.max_time
    thr = Thread.new { out = true if new_resource.block.call }

    if new_resource.timeout
      wait = Time.now
      until Time.now - wait >= max
        return if out
      end
      thr.kill
    else
      thr.join
    end
    return if out
    sleep new_resource.interval
  end
  raise 'Time out waiting!' unless out
end
