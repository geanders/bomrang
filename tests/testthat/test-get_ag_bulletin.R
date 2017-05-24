context("get_ag_bulletin")

# Test that get_ag_bulletin returns a data frame with 20 columns ------------------
test_that("get_ag_bulletin returns 20 columns", {
  skip_on_cran()
  BOM_bulletin <- get_ag_bulletin(state = "QLD")
  expect_equal(ncol(BOM_bulletin), 21)
  expect_named(
    BOM_bulletin,
    c(
      "obs_time_local",
      "obs_time_utc",
      "time_zone",
      "site",
      "name",
      "r",
      "tn",
      "tx",
      "twd",
      "ev",
      "tg",
      "sn",
      "t5",
      "t10",
      "t20",
      "t50",
      "t1m",
      "wr",
      "state",
      "lat",
      "lon"
    )
  )
})


# Test that get_ag_bulletin returns the requested state bulletin ------------------
test_that("get_ag_bulletin returns the bulletin for ACT/NSW", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "NSW"))
  expect_equal(BOM_bulletin[1, 19], "NSW")
})

test_that("get_ag_bulletin returns the bulletin for NT", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "NT"))
  expect_equal(BOM_bulletin[1, 19], "NT")
})

test_that("get_ag_bulletin returns the bulletin for QLD", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "QLD"))
  expect_equal(BOM_bulletin[1, 19], "QLD")
})

test_that("get_ag_bulletin returns the bulletin for SA", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "SA"))
  expect_equal(BOM_bulletin[1, 19], "SA")
})

test_that("get_ag_bulletin returns the bulletin for TAS", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "TAS"))
  expect_equal(BOM_bulletin[1, 19], "TAS")
})

test_that("get_ag_bulletin returns the bulletin for VIC", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "VIC"))
  expect_equal(BOM_bulletin[1, 19], "VIC")
})

test_that("get_ag_bulletin returns the bulletin for WA", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "WA"))
  expect_equal(BOM_bulletin[1, 19], "WA")
})

test_that("get_ag_bulletin returns the bulletin for AUS", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "AUS"))
  expect_equal(unique(BOM_bulletin[, 19]),
               c("NT", "NSW", "QLD", "SA", "TAS", "VIC", "WA"))
})

# Test that .validate_state stops if the state recognised ----------------------
test_that("get_ag_bulletin() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_ag_bulletin(state))
})