module controls.addControl;

struct AddControl {
    string[] args;
    string vcsDirectory;
    
    this(string[] args) {
        this.args = args;
    }
}