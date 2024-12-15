/**
 * The BankAccount class simulates a bank account.
 */
public class BankAccount {

    /**
     * The balance field stores the current balance.
     */
    private double balance;

    /**
     * The constructor initializes the balance to 0.
     */
    public BankAccount() {
        balance = 0;
    }

    /**
     * The deposit method adds money to the account.
     *
     * @param amount The amount to add to the balance.
     */
    public void deposit(double amount) {
        balance += amount;
    }

    /**
     * The withdraw method subtracts money from the account.
     *
     * @param amount The amount to subtract from the balance.
     */
    public void withdraw(double amount) {
        balance -= amount;
    }

    /**
     * The getBalance method returns the account balance.
     *
     * @return The current balance of the account.
     */
    public double getBalance() {
        return balance;
    }

    /**
     * The main method for the BankAccount class.
     * 
     * @param args Command line arguments (not used).
     */
    public static void main(String[] args) {
        BankAccount myAccount = new BankAccount();

        // Demonstrate deposit
        myAccount.deposit(200.00);
        System.out.println("Balance after deposit: " + myAccount.getBalance());

        // Demonstrate withdrawal
        myAccount.withdraw(50.00);
        System.out.println("Balance after withdrawal: " + myAccount.getBalance());
    }
}
