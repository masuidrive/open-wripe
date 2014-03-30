def within_window(name)
  sleep 0.5
  original = current_window
  use_window(name)
  yield
ensure
  use_window(original)
end
