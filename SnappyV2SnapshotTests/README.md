#  Snapshot Tests ReadMe

1. Tests should be recorded & asserted on iPhone 12 (iOS 15) simulator (to match our 'future' CI/CD configuration) 
2. To record a test, replace assert with record and run the test. Once test "fails", revert back to assert and run the test again to check it passes.
