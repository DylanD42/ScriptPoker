define start as integer
define stop as integer

prompt "Enter the start number: " into start
prompt "Enter the end number: " into stop 

define i as integer 

iterate i from start to stop {
  if i % 2 = 0 {
    display i & " is even."
  } else {
    display i & " is odd."
  }
}
