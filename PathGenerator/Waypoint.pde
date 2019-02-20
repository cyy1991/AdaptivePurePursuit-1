public class Waypoint {

    private Vector pos;

    public Waypoint(double x, double y) {
        this.pos = new Vector(x, y);
    }

    public Waypoint(Vector pos) {
        this.pos = new Vector(pos);
    }

    public double getX() {
        return this.pos.getX();
    }

    public double getY() {
        return this.pos.getY();
    }

    public Vector getVector() {
        return pos;
    }
}