public class ExampleClass {

    // Static fields
    private static int staticCounter;

    // Instance fields
    private int id;
    private String name;
    private double balance;

    enum Days {
    MONDAY, TUESDAY, WEDNESDAY
    }

    interface MyInterface {
    void doTask();
}


    // Static initializer
    static {
        staticCounter = 0;
        System.out.println("Static initializer called.");
    }

    // Instance initializer
    {
        balance = 0.0;
        System.out.println("Instance initializer called.");
    }

    // Default constructor
    public ExampleClass() {
        this.id = ++staticCounter;
        this.name = "Unnamed";
        System.out.println("Default constructor called.");
    }

    // Parameterized constructor
    public ExampleClass(String name, double balance) {
        this.id = ++staticCounter;
        this.name = name;
        this.balance = balance;
        System.out.println("Parameterized constructor called.");
    }

    // Getter for id
    public int getId() {
        return id;
    }

    // Getter for name
    public String getName() {
        return name;
    }

    // Setter for name
    public void setName(String name) {
        this.name = name;
    }

    // Getter for balance
    public double getBalance() {
        return balance;
    }

    // Setter for balance
    public void setBalance(double balance) {
        if (balance >= 0) {
            this.balance = balance;
        } else {
            System.out.println("Balance cannot be negative.");
        }
    }

    // Static method
    public static int getStaticCounter() {
        return staticCounter;
    }

    // Overriding the toString method
    @Override
    public String toString() {
        return "ExampleClass{id=" + id + ", name='" + name + "', balance=" + balance + '}';
    }

    // Main method for testing
    public static void main(String[] args) {
        ExampleClass obj1 = new ExampleClass();
        ExampleClass obj2 = new ExampleClass("Alice", 100.0);

        System.out.println(obj1);
        System.out.println(obj2);

        obj1.setName("Bob");
        obj1.setBalance(50.0);

        System.out.println(obj1);
        System.out.println("Static Counter: " + ExampleClass.getStaticCounter());
    }
}
