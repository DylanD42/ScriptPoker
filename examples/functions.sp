function add(a as integer, b as integer) returns integer {
  return a + b
}

procedure announce(a as integer) {
  display "Sum of " & a & " and " & a + 1 & " is " & add(a, a + 1)
}

define i as integer
iterate i from 1 to 10 {
  announce(i)
}
