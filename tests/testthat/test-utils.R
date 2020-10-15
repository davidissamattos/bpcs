test_that("Logit test if x is in bounds", {
  expect_error(logit(-1),'Error!')
  expect_error(logit(10),'Error!')
})

test_that('Known logit values', {
  expect_equal(logit(0.5),0)
  expect_equal(logit(1),Inf)
  expect_equal(logit(0),-Inf)
})


test_that('Known inv logit values', {
  expect_lt(inv_logit(5)-0.9933071, 0.001)
  expect_lt(inv_logit(-5)-0.006692851,  0.001)
  expect_lt(inv_logit(0)-0.5, 0.001)
})
