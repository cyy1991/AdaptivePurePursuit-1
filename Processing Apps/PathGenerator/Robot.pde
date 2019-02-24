class Robot {

    Vector pos;
    double velocity;
    double angle;
    double angularVelocity;

    double leftSpeed;
    double rightSpeed;

    public Robot() {
        pos = new Vector(600, 300);
        velocity = 0.0;
        angle = 0.0;
        angularVelocity = 0.0;

        leftSpeed = 0.0;
        rightSpeed = 0.0;
    }

    public void setLeft(double speed) {
        leftSpeed = speed;
    }

    public void setRight(double speed) {
        rightSpeed = speed;
    }

    public void update() {
        this.velocity = (this.leftSpeed + this.rightSpeed) / 2.0;
        this.angularVelocity = (this.leftSpeed - this.rightSpeed) / DRIVE_WIDTH;

        this.angle += this.angularVelocity;
        this.pos = this.pos.add(new Vector(this.velocity * Math.cos(this.angle - Math.PI / 2.0),
            this.velocity * Math.sin(this.angle - Math.PI / 2.0)));

        this.leftSpeed = 0;
        this.rightSpeed = 0;
    }

    public void show() {
        rectMode(CENTER);
        fill(120);
        stroke(0);
        pushMatrix();
            translate((float) this.pos.getX(), (float) this.pos.getY());
            rotate((float) angle);
            rect(0, 0, (float) DRIVE_WIDTH, (float) DRIVE_WIDTH * 2.0);
        popMatrix();
    }

    public double getX() {
        return pos.getX();
    }

    public double getY() {
        return pos.getY();
    }

    public Vector getPos() {
        return pos;
    }
}
