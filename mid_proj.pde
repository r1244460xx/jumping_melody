
import processing.serial.*;
import gifAnimation.*;
import ddf.minim.*;
import java.util.LinkedList;

class Cursor {
    public int x;
    public int y;
    public int ans;
    public int time;
    public int type;
    //public int tick;
    
    Cursor(int k, int t) {
        x = 1600;
        time = t;         
        type = k;
        //tick = 0;
        if(type == 1) {
            ans = int(random(4));
            y = 700;    
        }           
        else {
            //ans = int(random(4));
            ans = 0;
            y = 450;
        }                  
    }
    
    void draw() {      //draw map as the current position
        if(type == 0) {
            switch(ans) {
                case 0:
                    image(up_up, x, y, 200, 200);
                    break;
                
                case 1:
                    image(up_left, x, y, 200, 200);
                    break;
                
                case 2:
                    image(up_down, x, y, 200, 200);
                    break;
                
                case 3:
                    image(up_right, x, y, 200, 200);
                    break;
            }
        }        
        else {
            switch(ans) {
                case 0:
                    image(down_up, x, y, 200, 200);
                    break;
                
                case 1:
                    image(down_left, x, y, 200, 200);
                    break;
                
                case 2:
                    image(down_down, x, y, 200, 200);
                    break;
                
                case 3:
                    image(down_right, x, y, 200, 200);
                    break;
            }
        }
    }
    
    void move() {
        x -= cursor_step;  //not smooth, but fast
    }
} 

class Evaluate {
    public int counter;
    public int eval;
    
    Evaluate(int e) {
        eval = e;
        counter = 15;
        if(e == 2) {
            if(is_bonus)
                score += 20;
            else
                score += 10;
        }
        else if(e == 3) {
            if(is_bonus)
                score += 40;
            else
                score += 20;
        }
    }
    
    void draw() {
        if(counter > 0) {
            switch(eval) {
            case 1:
                image(bad, 1350, 100);
                break;
                
            case 2:
                image(normal, 1350, 100);
                break;
                
            case 3:
                image(excellent, 1350, 100);
                break;
                
            default:
                break;
            }
            counter--;
        }
    }   
}

boolean is_standby = true;
boolean is_bonus = true;

PImage backgnd_img1, backgnd_img2, logo, bonus;
PImage up_up, up_left, up_down, up_right;
PImage down_up, down_left, down_down, down_right, down_middle;
PImage bad, normal, excellent;

int start_time = 0;

int score = 0;
int combo = 0;

int curr_cursor = 0;

int frame = 0;
int fps_time = 0;
int frame_1_sec = 0;

final int fps = 40;
final int cursor_speed = 1000;
final int cursor_step = 30;

Evaluate evaluation;
BufferedReader reader;
LinkedList<Cursor> beatmap = new LinkedList<Cursor>();
LinkedList<Cursor> up_queue = new LinkedList<Cursor>();
LinkedList<Cursor> down_queue = new LinkedList<Cursor>();

Serial port;
Minim minim;  //music obj
AudioPlayer player = null; //music player obj
AudioPlayer up_sound = null;
AudioPlayer down_sound = null;

void img_init() {
    try {
        imageMode(CENTER);
        backgnd_img2 = loadImage("background.png"); //Make a beautiful background-image
        logo = loadImage("logo.png");  //Make a beautiful logo image  
        bonus = loadImage("bonus.png");
        backgnd_img1 = loadImage("background_1.png");
        backgnd_img2 = loadImage("background_2.png"); 
        
        up_up = loadImage("up_up2.png");
        up_left = loadImage("up_left2.png");
        up_down = loadImage("up_down2.png");
        up_right = loadImage("up_right2.png");
        
        down_up = loadImage("down_up3.png");
        down_left = loadImage("down_left3.png");
        down_down = loadImage("down_down3.png");
        down_right = loadImage("down_right3.png");
        
        bad = loadImage("bad.png");
        normal = loadImage("normal.png");
        excellent = loadImage("excellent.png");
    }
    catch(Exception e) {
        println("Please check your png file integration");
        retry();
    }
}

void port_init() {
    try {
        port = new Serial(this, Serial.list()[0], 115200);
    }
    catch(Exception e) {
        println("Please check your serial connection");
        retry();  
    }
}

void sound_init() {
    minim = new Minim(this);
    player = minim.loadFile("g_major_cut.mp3", 2048); //(filename, buffersize);
    up_sound = minim.loadFile("up_sound.wav");
    down_sound = minim.loadFile("down_sound.wav");
}

void beatmap_load() {
    String line;
    while(true) {
        try {
            line = reader.readLine();             
        }
        catch(IOException e) {
            e.printStackTrace();
            line = null;
        }
        if(line == null) {
            break;
        }
        String[] data = split(line, ',');       
        Cursor obj = new Cursor(int(data[1]), int(data[2]));
        beatmap.add(obj);
    }
}

void beatmap_init() {
    try {
        reader = createReader("g_major.csv");
    }
    catch(Exception e) {
        println("Please check your beatmap file");
        e.printStackTrace();
    }
    beatmap_load();
    
}

void draw_background() {
    if(is_standby) {  //standby page         
        background(backgnd_img1);                    
        String any_key = "Please key ENTER to start!";
        fill(#FFFFFF);
        textSize(80);
        textAlign(CENTER, CENTER);
        text(any_key, 800, 450); //Hope to create fading in out text
    }
    
    else {      //gaming page
        background(backgnd_img2);
        if(is_bonus) {
            image(bonus, 800, 100);            
        }                   
    }
}

void draw_cursor() {
    switch(curr_cursor) {
        case 0:
            image(up_up, 400, 450, 200, 200); 
            break;
            
        case 1:
            image(up_left, 400, 450, 200, 200); 
            break; 
            
        case 2:
            image(up_down, 400, 450, 200, 200); 
            break;
        
        case 3:
            image(up_right, 400, 450, 200, 200); 
            break; 
            
        default:
            image(up_up, 400, 450, 200, 200); 
            break;
    }
    
    for(int i = 0; i < up_queue.size(); i++) {
        up_queue.get(i).draw();
    }
    
    for(int i = 0; i < down_queue.size(); i++) {
        down_queue.get(i).draw();
    }
}

void move_cursor() {                        //move all cursor
    for(int i = 0; i < up_queue.size(); i++) {         
        up_queue.get(i).move();
    }
    
    for(int i = 0; i < down_queue.size(); i++) {        
        down_queue.get(i).move();
    }
    
    if(up_queue.size() > 0) {
        if(up_queue.element().x <= 400) {
            if(up_queue.element().ans != curr_cursor) {  //remove up cursors
                evaluation = new Evaluate(1);
                combo = 0;
            }
            else {
                evaluation = new Evaluate(3);
                up_sound.rewind();
                up_sound.play();               
                combo++;
            }
            up_queue.remove();
        }
    }
    
    if(down_queue.size() > 0) {                 //remove down cursors         
        if(down_queue.element().x <= 100) {
            down_queue.remove();
            evaluation = new Evaluate(1);
            combo = 0;
        }
    }
}

void draw_score() {
    //println(score);
    fill(0);
    textSize(48);
    text(score, 400, 75);
    if(combo > 0) {
        text(combo + " combo", 400, 175);
    }
}

void chk_down_res(int res) {
    if(down_queue.size()>0) {  //not sensitive at all!
        if(down_queue.element().x < 550 && down_queue.element().x > 250) {
            if(down_queue.element().ans == res) {
                down_queue.remove();
                evaluation = new Evaluate(3);
                combo++;
            }
            else {
                down_queue.remove();
                evaluation = new Evaluate(1);
                combo = 0;
            }       
        }         
        else if(down_queue.element().x < 700 && down_queue.element().x > 100) {
            if(down_queue.element().ans == res){
                down_queue.remove();
                evaluation = new Evaluate(2);
                combo++;
            }
            else {
                down_queue.remove();
                evaluation = new Evaluate(1);
                combo = 0;
            }
        }        
    } 
}

void update_queue() {
    if(beatmap.size() != 0) {
        if(beatmap.element().time - (millis() - start_time) <= cursor_speed) {   //From side to check point taking one second
            if(beatmap.element().type == 0) {
                up_queue.add(beatmap.remove());
            }
            else if(beatmap.element().type == 1) {
                down_queue.add(beatmap.remove());
            }
        }
    }                  
}

void retry() {
    //port.stop();
    //minim.stop();
    combo = 0;
    score = 0;
    player.pause();
    player.rewind();
    beatmap.clear();
    up_queue.clear();
    down_queue.clear();
    evaluation = new Evaluate(4);
    beatmap_init();
} 

void read_port() {
    if(port.available() > 0) {
        int val = port.read();
        switch(val) {
            case '8':
                curr_cursor = 0;
                break;
        
            case '4':
                curr_cursor = 1;
                break;
                
            case '2':
                curr_cursor = 2;
                break;
                
            case '6':
                curr_cursor = 3;
                break;
        }
    }
}
 
void draw_true_fps() {
    frame++;
    if(millis() - fps_time >= 1000) {
        fps_time = millis();
        frame_1_sec = frame;       
        frame = 0;
    }
    println(frame_1_sec);
}


void draw_fps() {
    fill(#FFFFFF);
    textSize(32);
    text("FPS: " + int(frameRate), 150, 850);
}

/*
void keyReleased() {
    switch(keyCode){
        case LEFT:
            break;
            
        case RIGHT:
            break;
            
        case DOWN: 
            break;
            
        case UP:
            break;   
    }
}*/

void keyPressed() {
    switch(keyCode){
        case UP:
            chk_down_res(0);
            down_sound.rewind();
            down_sound.play(); 
            break; 
            
        case LEFT:
            chk_down_res(1);
            down_sound.rewind();
            down_sound.play(); 
            break;   
            
        case DOWN:
            chk_down_res(2);
            down_sound.rewind();
            down_sound.play(); 
            break;   
            
        case RIGHT:
            chk_down_res(3);
            down_sound.rewind();
            down_sound.play(); 
            break;        
    }
    
    switch(key) {
        case 'q':
            is_standby = true;
            retry();
            break;
                       
        case '8':
            curr_cursor = 0;
            break;
            
        case '4':
            curr_cursor = 1;
            break;
            
        case '2':
            curr_cursor = 2;
            break;
            
        case '6':
            curr_cursor = 3;
            break;
            
        case '\n':
            if(is_standby) {
                is_standby = false;
                start_time = millis();
            }
            break;
    }   
}

void setup() {
    //port_init();
    img_init();
    sound_init(); 
    beatmap_init();
    size(1600, 900);
    frameRate(fps);  //Now it reached 40 FPS
    evaluation = new Evaluate(4);   //initalize score obj
    //Start a thread
}

void draw() {  //main function of this program        
    draw_background();
    if(!is_standby) {    //gaming mode
        update_queue();
        move_cursor();                    
        draw_cursor();                
        draw_true_fps();
        evaluation.draw();
        draw_score();              
        draw_fps();
        player.play();      
        //read_port();   
    }    
}
