jserror-rails
=============

Automatically inserts try catches around coffeescript code just add a .debug extension

On an exception calls out a method called javascript_error() with an object
```
javascript_error({
                  name: NAME,  
                  error_message: ERROR MESSAGE, 
                  error_name: ERROR NAME, 
                  code_block: BLOCK OF CODE WHICH ERRORED (with \n replaced with [::n::],
                  arguments: FUNCTION ARGUMENTS
});
```
