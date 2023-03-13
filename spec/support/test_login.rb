def clear_session
  visit "/sessions/test"
end

def test_login(username, do_clear_session=true)
  clear_session if do_clear_session
  visit "/sessions/test?username=#{username}"
  sleep 2.0
  wait_until_visible "#nav-username-link"
  expect(evaluate_script('session.username()')).to eq username
end
