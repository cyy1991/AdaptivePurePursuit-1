public class Vector {

    private double x;
    private double y;
    
    private double mag;
    private double magSquared;

    /**
     * 2D Vector class for handling calculations
     * All functions will not modify the current object
     */

    public Vector(double x, double y) {
        this.x = x;
        this.y = y;

        this.mag = -1;
        this.magSquared = -1;
    }

    public Vector(Vector copy) {
        this.x = copy.getX();
        this.y = copy.getY();

        this.mag = -1;
        this.magSquared = -1;
    }

    public double getX() {
        return this.x;
    }

    public double getY() {
        return this.y;
    }

    public double getMagSquared() {
        if(this.magSquared == -1) {
            this.magSquared = this.x * this.x + this.y * this.y;
        }
        return this.magSquared;
    }

    public double getMag() {
        if(this.mag == -1) {
            this.mag = Math.sqrt(getMagSquared());
        }
        return this.mag;
    }

    public Vector normalize() {
        double newX = this.x /= getMag();
        double newY = this.y /= getMag();
        
        return new Vector(newX, newY);
    }

    public Vector add(Vector vector) {
        return new Vector(this.getX() + vector.getX(), this.getY() + vector.getY());
    }

    public Vector sub(Vector vector) {
        return new Vector(this.getX() - vector.getX(), this.getY() - vector.getY());
    }

    public Vector mult(double num) {
        return new Vector(this.getX() * num, this.getY() * num);
    }

    public double dot(Vector vector) {
        return this.getX() * vector.getX() +  this.getY() * vector.getY();
    }

    public void printInfo() {
        System.out.println("X: " + getX() + ", Y: " + getY());
    }

    public void printExtInfo() {
        System.out.println("X: " + getX() + ", Y: " + getY() + ", Mag: " + getMag());
    }
}