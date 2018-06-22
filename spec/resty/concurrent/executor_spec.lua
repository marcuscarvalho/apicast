local Executor = require('resty.concurrent.executor')

describe('ImmediateExecutor', function()
    describe('.from_options', function()
        it('has default executor', function()
            assert(Executor.from_options{ })
        end)

        it('has passes through executor', function()
            local executor = { 'something' }

            assert.equal(executor, Executor.from_options{ executor = executor })
        end)
    end)
end)
