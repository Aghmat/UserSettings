# Zapper Assessment

This repository contains my solution to the Zapper Assessment. The assessment includes two main tasks: Database Design and User Settings Management.

## File Structure
- `Transactions.sql` - Solution for **Question 1: Database Design**
- `Question 2.1`
  - `UserSettingsChecker.cs` - Implementation of the function to check if a specific user feature is enabled.
  - `UserSettingsCheckerTests.cs` - Unit tests for `UserSettingsChecker`.
- `Question 2.2`
  - `UserSettingsManager.cs` - Implementation of functions to store and retrieve user settings in the least amount of space.
  - `UserSettingsManagerTests.cs` - Unit tests for `UserSettingsManager`.

## Question 1: Database Design

At Zapper, transactions between customers and merchants need to be tracked. The SQL in `Transactions.sql` defines the data structures required to track these transactions.

### Tables:
1. `Customers` - Stores customer details.
2. `Merchants` - Stores merchant details.
3. `Transactions` - Stores the transaction data, linking customers and merchants with relevant details like amount and timestamp.

## Question 2: User Settings

### 2.1 - Checking if a Feature is Enabled

The user settings are represented as a binary string where each position corresponds to a specific feature. The function implemented in `UserSettingsChecker.cs` allows us to determine whether a specific feature is enabled based on its position in the string.

#### Test Cases:
| Input                    | Output  |
|---------------------------|---------|
| settings = `00000000`, setting = 7  | `false`  |
| settings = `00000010`, setting = 7  | `true`   |
| settings = `11111111`, setting = 4  | `true`   |

### 2.2 - Storing User Settings

The implementation in `UserSettingsManager.cs` focuses on efficiently reading and writing user settings to a file using the least amount of space. It uses bitwise operations to manage the 8 boolean settings and store them compactly.

### How to Run Tests

To verify the correctness of the implementations, the following test files are included:
- `UserSettingsCheckerTests.cs` - Contains unit tests for checking if a feature is enabled.
- `UserSettingsManagerTests.cs` - Contains unit tests for reading and writing user settings.

## Conclusion

The solutions provided aim to be simple yet effective, leveraging SQL for database design and C# for handling boolean settings efficiently.

Feel free to explore the code and run the tests for verification. If you have any questions, please don't hesitate to reach out.

