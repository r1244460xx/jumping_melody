
import processing.serial.*;
import gifAnimation.*;
import ddf.minim.*;
import java.util.LinkedList;

class Beat {
    static final int SIZE = 200;
    static final int DISTANCE = 1200;
    static final float FAST = 1000.0;
    static final float MIDDLE = 1500.0;
    static final float SLOW = 2000.0;
    float speed = MIDDLE;
    public int x;
    public int y;
    public int ans;
    public int time;
    public int effect;      
    Beat() {
    }
       
    void move() {
       x = width - int((DISTANCE / speed) * ((millis() - game.start_time) - (time - speed)));
    }
} 

class Volume extends Beat {
    static final int CHK_X = 400;
    static final int CHK_Y = 450;
    static final int UP = 0;
    static final int LEFT = 1;
    static final int DOWN = 2;
    static final int RIGHT = 3;
    
    Volume(int t, int e) {
        x = width;         
        time = t;
        ans = int(random(4));
        if(ans == 2) ans = 0;
        ans = 0;
        y = CHK_Y;  
        effect = e;
    }
    
    Volume() {
    }
    
    void draw(){
        switch(ans) {
                case 0:
                    image(vol_up, x, y, SIZE, SIZE);
                    break;
                
                case 1:
                    image(vol_left, x, y, SIZE, SIZE);
                    break;
                
                case 2:
                    image(vol_down, x, y, SIZE, SIZE);
                    break;
                
                case 3:
                    image(vol_right, x, y, SIZE, SIZE);
                    break;
        }
    }
}

class Arrow extends Beat {
    static final int CHK_X = 400;
    static final int CHK_Y = 700;
    static final int UP = 0;
    static final int LEFT = 1;
    static final int DOWN = 2;
    static final int RIGHT = 3;
    
    Arrow(int t, int e) {
        ans = int(random(4));
        y = CHK_Y;
        x = width;         
        time = t;
        effect = e;
    }
    
    Arrow() {
    }
    
    void draw(){
        switch(ans) {
            case 0:
                image(arr_up, x, y, SIZE, SIZE);
                break;
            
            case 1:
                image(arr_left, x, y, SIZE, SIZE);
                break;
            
            case 2:
                image(arr_down, x, y, SIZE, SIZE);
                break;
            
            case 3:
                image(arr_right, x, y, SIZE, SIZE);
                break;
        }
    }
}

class Rank {
    static final int SIZE_X = 400;
    static final int SIZE_Y = 250;
    static final int BAD = 1;
    static final int NORMAL = 2;
    static final int EXCELLENT = 3;
    int rank;
    int timer = 0;
    Rank(int e) {
        if(timer == 0) {
            timer = millis();
        }
        rank = e;
        if(e == NORMAL) {
            if(game.is_bonus) {
                values.score += 20;
            }
            else {
                values.score += 10;
            }
        }
        else if(e == EXCELLENT) {
            if(game.is_bonus) {
                values.score += 40;
            }
            else {
                values.score += 20;
            }
        }
    }
    
    Rank() {
    }
      
    void draw() {
        if(millis() - timer < 200) {
            switch(rank) {
            case BAD:
                image(bad_img, SIZE_X, SIZE_Y);
                break;
                
            case NORMAL:
                image(normal_img, SIZE_X, SIZE_Y);
                break;
                
            case EXCELLENT:
                image(excellent_img, SIZE_X, SIZE_Y);
                break;
                
            default:
                break;
            }
        }
    }   
}

class Value {
    static final int X = 50;
    static final int Y = 75;
    int score = 0;
    int combo = 0;
    int max_combo = 0;
    int excel = 0;
    int normal = 0;
    int bad = 0;
    
    void combo_up() {
        combo++;
        if(max_combo <= combo) {
            max_combo = combo;
        }
    }
    
    void combo_zero() {
        combo = 0;
    }
    
    void draw() {
        fill(#FFFFFF);
        textSize(48);
        textAlign(LEFT, CENTER);
        text("SCORE: " + score, X, Y);
        textAlign(CENTER, CENTER);
        if(combo > 0) {
            text(combo + " COMBO", 150, 700);
        }
    }
    
    Value() {
    }
}

class Mode {
    static final int INTRO = 0;
    static final int MENU = 1;
    static final int GAME = 2;
    static final int RESULT = 3;
    int mode = INTRO;
    
    Mode() {
    
    }
    
    void to_intro() {
        mode = INTRO;
    }
    
    void to_menu() {
        mode = MENU;
    }
    
    void to_game() {
        mode = GAME;
    }
    
    void to_result() {
        mode = RESULT;
    }
    
}

class Intro {
    static final int WORD_X = 800;
    static final int WORD_Y = 450;
    AudioPlayer intro;
    int op = 0;
    boolean op_f = true;
    Intro() {
        intro = minim.loadFile("intro.mp3");
    }
    
    void draw() {
        background(backgnd_intro);                    
        String any_key = "Please press JoyStick to start!";
        if(op_f) {
            op++;
            if(op == 256) {
                op_f = false;
                op = 255;
            }
        }
        else {
            op--;
            if(op == -1) {
                op_f = true;
                op = 0;
            }
        }
        fill(#FFFFFF, op);
        textSize(80);
        text(any_key, WORD_X, WORD_Y); //Hope to create fading in out text
        fill(#FFFFFF);
    }  
    
    void leave() {
        intro.pause();
        intro.rewind();
    }
    
    void play() {
        if(!intro.isPlaying()) {
            intro.play();
        }
    }
}

class Menu {
    String song_name;
    int song_ptr = 0;
    AudioPlayer song = null;
    
    Menu() {
        String path = sketchPath();
        File[] files = listFiles(path);
        for (int i = 0; i < files.length; i++) { 
            if(files[i].getName().contains(".")){
                String[] pieces = split(files[i].getName(), '.');
                if(pieces[1].equals("csv")) {
                    song_list.add(pieces[0]);
                }
            }
        }
        song_name = song_list.get(song_ptr);
        song = minim.loadFile(song_name + ".mp3");
    }
    
    void play() {
        if(!song_name.equals(song_list.get(song_ptr))) {
            song.close();
            song_name = song_list.get(song_ptr);
            song = minim.loadFile(song_list.get(song_ptr) + ".mp3");
        }      
        song.play();
    }
    
    void leave() {
        song.pause();
        song.rewind();
    }
    
    void draw() {  
        background(backgnd_intro);
        rectMode(CENTER);
        int size_x = 800;
        int size_y = 200;
        int x = width - size_x / 2;
        int y = 450;
        int offset = 30;
        int len = song_list.size();
        if(len > 7) {
            len = 7;
        }
        if(len > 0) {
            fill(207, 169, 114);
            strokeWeight(10);
            strokeJoin(ROUND);
            rect(x, y, size_x, size_y);
            textSize(80);
            fill(#FFFFFF);
            int index = song_ptr;
            text(song_list.get(index), x, y);
                          
            for(int i = 1; i <= ceil((len - 1) / 2.0); i++) {
                size_x = 800 - i * (800 - 400) / 3;
                size_y = 100;
                x = width - size_x / 2;
                y = 600 + (i - 1) * 100 + offset; 
                fill(207, 169, 114);
                rect(x, y, size_x, size_y);         
                textSize(48);
                fill(0);
                index = (song_ptr + i) % len;
                if(index < 0) {
                    index = song_list.size() + index;
                }
                text(song_list.get(index), x, y);
            } 
                       
            for(int i = 1; i <= floor((len - 1) / 2.0); i++) {
                size_x = 800 - i * (800 - 400) / 3;
                size_y = 100;
                x = width - size_x / 2;
                y = 300 - (i - 1) * 100 - offset; 
                fill(207, 169, 114);
                rect(x, y, size_x, size_y);          
                textSize(48);
                fill(0);
                index = (song_ptr - i) % len;
                if(index < 0) {
                    index = song_list.size() + index;
                }
                text(song_list.get(index), x, y);
            }           
        }
        textAlign(LEFT, CENTER);
        textSize(60);
        fill(#FFFFFF);
        String str = "";
        switch(int(beat.speed)) {
            case 1000:
                str = "FAST";
                break;
            case 1500:
                str = "MIDDLE";
                break;
            case 2000:
                str = "SLOW";
                break;
        }
        text("SPEED: " + str, 150, 475);
        textAlign(CENTER, CENTER);
    }    
}

class Game {
    static final int BASS = 0;
    static final int MIDDLE = 1;
    static final int TREBLE = 2;
    static final int CYMBAL = 3; 
    static final int HIHAT_CYMBAL = 4;
    static final int REST = 5;
    int start_time = 0; 
    int vol_chk = 0;
    int map_size = 0;
    int beated = 0;
    int end_timer = 0;
    int start_timer = 0;
    boolean is_bonus = false;
    int bonus_start;
    int bonus_end;
    AudioPlayer song;
    AudioPlayer middle = null, cymbal = null, bass = null, treble = null, hihat_cymbal = null;
    
    Game() {
        sound_init();
        beatmap_init(); //<>//
        rank = new Rank();   
        values = new Value();
    }
    
    void sound_init() {
        hihat_cymbal = minim.loadFile("hihat_cymbal.wav");
        middle = minim.loadFile("middle.wav");
        cymbal = minim.loadFile("cymbal.wav");
        bass = minim.loadFile("bass.wav");
        treble = minim.loadFile("treble.wav"); 
        song = minim.loadFile(menu.song_name + ".mp3");
    }
           
    void beatmap_init() {
        try {
            reader = createReader(menu.song_name + ".csv");
        }
        catch(Exception e) {
            println("Please check your beatmap file");
            e.printStackTrace();
        }
        String line;
        vol_beatmap.clear();
        arr_beatmap.clear();
        vol_queue.clear();
        arr_queue.clear();
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
            if(int(data[1]) == 0) {
                Volume vol = new Volume(int(data[2]), int(data[3]));
                vol_beatmap.add(vol);
                map_size++;
            }
            else if(int(data[1]) == 1) {
                Arrow arr = new Arrow(int(data[2]), int(data[3]));
                arr_beatmap.add(arr);
                map_size++;
            }
            else if(int(data[1]) == 3) {
                bonus_start = int(data[2]);
                bonus_end = int(data[3]);
            }
        }   
    }
    
    void play() {
        song.play();
    }
    
    void leave() {
        song.close();
    }
    
    void again() {
        song.pause();
        song.rewind();
    }
    
    void pause() {
        song.pause();
    }
    
    void update_queue() {   
        while(vol_beatmap.size() > 0) {
            if(vol_beatmap.element().time - (millis() - start_time) <= beat.speed * 2) {   
                vol_queue.add(vol_beatmap.remove());
            }
            else {
                break;
            }
        }       
        while(arr_beatmap.size() > 0) {
            if(arr_beatmap.element().time - (millis() - start_time) <= beat.speed * 2) {   
                arr_queue.add(arr_beatmap.remove());
            }
            else {
                break;
            }
        }
                          
    }
    
    void move_beat() {                      
        for(int i = 0; i < vol_queue.size(); i++) {         
            vol_queue.get(i).move();
        }
        
        for(int i = 0; i < arr_queue.size(); i++) {        
            arr_queue.get(i).move();
        }
        /*Check the answer of volume beat*/
        if(vol_queue.size() > 0) {
            //if(abs(vol_queue.element().time - (millis() - start_time)) <= 15) {
            if(abs(vol_queue.element().x - 400) <= 15) {
                if(vol_queue.element().ans != vol_chk) {  
                    rank = new Rank(Rank.BAD);
                    values.combo_zero();
                    values.bad++;
                }
                else {                
                    rank = new Rank(Rank.EXCELLENT);
                    play_effect(vol_queue.element().effect);              
                    values.combo_up();
                    values.excel++;
                    
                }
                game.beated++;
                vol_queue.remove();
            }
        }
        /*Remove miss arrow*/
        if(arr_queue.size() > 0) {                        
            if(arr_queue.element().x < Arrow.CHK_X - Beat.SIZE / 2) {
                arr_queue.remove();
                game.beated++;
                rank = new Rank(Rank.BAD);
                values.combo_zero();
            }
        }
    }
      
    void draw() {
        background(backgnd_game);
        if(is_bonus) {
            image(bonus, 800, 100);            
        }     
       /* switch(vol_chk) {
            case Volume.UP:
                image(vol_up, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
                break;
                
            case Volume.LEFT:
                image(vol_left, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
                break; 
                
            case Volume.DOWN:
                image(vol_down, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
                break;
            
            case Volume.RIGHT:
                image(vol_right, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
                break; 
                
            default:
                image(vol_up, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
                break;
        }*/
        
        if(arr_queue.size() > 0) {
            switch(arr_queue.element().ans) {
              case Arrow.UP:
                  image(arr_up_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
                  break;
                  
              case Arrow.LEFT:
                  image(arr_left_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
                  break; 
                  
              case Arrow.DOWN:
                  image(arr_down_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
                  break;
              
              case Arrow.RIGHT:
                  image(arr_right_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
                  break;            
            }
        }
        else {
            image(arr_null_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE);
        }
        
        for(int i = 0; i < vol_queue.size(); i++) {
            vol_queue.get(i).draw();
        }
        
        for(int i = 0; i < arr_queue.size(); i++) {
            arr_queue.get(i).draw();
        }
    }
    
    void play_effect(int s) {
        switch(s) {
            case BASS:
                bass.rewind();
                bass.play();
                break;
            
            case MIDDLE: 
                middle.rewind();
                middle.play();
                break;
                
            case TREBLE:
                treble.rewind();
                treble.play();
                break;
             
            case CYMBAL:
                cymbal.rewind();
                cymbal.play();
                break;   
            
            case HIHAT_CYMBAL:
                hihat_cymbal.rewind();
                hihat_cymbal.play();
                break;   
                
            case REST:
                break;
        }
    }
    
    void chk_arr_res(int res) {
        if(arr_queue.size()>0) {  
            if(abs(arr_queue.element().time - (millis() - start_time)) < 50 && abs(arr_queue.element().x - Arrow.CHK_X) <= Beat.SIZE / 2) {
                if(arr_queue.element().ans == res) {
                    play_effect(arr_queue.element().effect);
                    rank = new Rank(Rank.EXCELLENT);
                    values.combo_up();
                    values.excel++;
                }
                else {
                    rank = new Rank(Rank.BAD);
                    values.combo_zero();
                    values.bad++;
                }
                arr_queue.remove();
                game.beated++;
            }         
            else if(abs(arr_queue.element().time - (millis() - start_time)) < 100 && abs(arr_queue.element().x - Arrow.CHK_X) <= Beat.SIZE / 2) {
                if(arr_queue.element().ans == res) {
                    play_effect(arr_queue.element().effect);
                    rank = new Rank(Rank.NORMAL);
                    values.combo_up();
                    values.normal++;
                }
                else {
                    rank = new Rank(Rank.BAD);
                    values.combo_zero();
                    values.bad++;
                }
                arr_queue.remove();
                game.beated++;
            }        
        } 
    } 
    
    void chk_end() {
        if(map_size == beated) {
            if(end_timer == 0) {
                end_timer = millis();
            }
            else {
                if(millis() - end_timer > 3000) {
                    game.leave();
                    mode.to_result();
                }
            }
            
        }
    }
    
    void retry() {
        values = new Value();
        rank = new Rank();
        game.again();
        vol_beatmap.clear();
        arr_beatmap.clear();
        vol_queue.clear();
        arr_queue.clear();
        game.beatmap_init();    
    } 
    void bonus_chk() {
        if(bonus_start <= (millis() - start_time)) {
            is_bonus = true;
        }
        if(bonus_end <= (millis() - start_time)) {
            is_bonus = false;
        }
    }
}

class Result {
    AudioPlayer applause;
    float acc;
    Result() {
        applause = minim.loadFile("applause.mp3");
    }
       
    void draw() {
        acc = 100.0 * (values.excel + values.normal) / game.map_size;
        acc = round(acc * 100.0);
        acc /= 100.0;
        background(backgnd_result);
        fill(#FFFFFF);
        textSize(60);
        if(acc > 95.0) {
            image(rank_s, width / 2, height / 2, 370, 600);
        }
        else if(acc > 90.0) {
            image(rank_a, width / 2, height / 2, 370, 600);
        }
        else if(acc > 85.0) {
            image(rank_b, width / 2, height / 2, 370, 600);
        }
        else if(acc > 80.0) {
            image(rank_c, width / 2, height / 2, 370, 600);
        }
        else {
            image(rank_d, width / 2, height / 2, 370, 600);
        }
        image(score, width / 2 - 600, height * 3 / 4, 200, 100);
        text(values.score + "", width / 2 - 600, height * 3 / 4 + 70, 200, 100);
        image(accuracy, width / 2 - 360, height * 3 / 4, 200, 100);
        text(acc + "%", width / 2 - 360, height * 3 / 4 + 70, 200, 100);
        image(combo, width / 2 - 120, height * 3 / 4, 200, 100);
        text(values.max_combo + "", width / 2 - 120, height * 3 / 4 + 70, 200, 100);
        image(excellent_img, width / 2 + 120, height * 3 / 4, 200, 100);
        text(values.excel + "", width / 2 + 120, height * 3 / 4 + 70, 200, 100);
        image(normal_img, width / 2 + 360, height * 3 / 4, 200, 100);
        text(values.normal + "", width / 2 + 360, height * 3 / 4 + 70, 200, 100);
        image(bad_img, width / 2 + 600, height * 3 / 4, 200, 100);
        text(values.bad + "", width / 2 + 600, height * 3 / 4 + 70, 200, 100);
    }
    
    void play() {
        applause.play();
    }
    
    void leave() {
        applause.pause();
        applause.rewind();
    }

}

int frame = 0;
int fps_time = 0;
int frame_1_sec = 0;

Rank rank;
Mode mode;
Intro intro;
Menu menu;
Game game;
Result result;
Beat beat;
BufferedReader reader;

LinkedList<Volume> vol_queue = new LinkedList<Volume>();
LinkedList<Arrow> arr_queue = new LinkedList<Arrow>();
LinkedList<Volume> vol_beatmap = new LinkedList<Volume>();
LinkedList<Arrow> arr_beatmap = new LinkedList<Arrow>();
ArrayList<String> song_list = new ArrayList<String>();

Serial port;
Minim minim;  //music obj

Value values;

boolean serial_flag = true;

void port_init() {
    try {
        port = new Serial(this, "COM3", 115200);
    }
    catch(Exception e) {
        println("Please check your serial connection");
        serial_flag = false;
    }
}

void read_port() {
    if(port.available() > 0) {
        int val = port.read();
        switch(mode.mode) {
            case Mode.INTRO:
                if(val == '8') {
                    mode.to_menu();
                    intro.leave();
                }
                break;
                
            case Mode.MENU:
                switch(val){
                    case '0':
                        menu.song_ptr = (menu.song_ptr + 1) % song_list.size();
                        break; 
                        
                    case '1':
                        break;   
                        
                    case '2':
                        menu.song_ptr = (menu.song_ptr - 1) % song_list.size();
                        if(menu.song_ptr < 0) {
                            menu.song_ptr += song_list.size();
                        }
                        break;   
                        
                    case '3':
                        break; 
                    
                    case '4':
                        beat.speed = Beat.MIDDLE;
                    break;
                    
                    case '5':
                        beat.speed = Beat.FAST;
                    break;
                    
                    case '7':
                        beat.speed = Beat.SLOW;
                    break;
                       
                    case '8':
                        mode.to_game();
                        menu.leave();
                        game = new Game();
                        break;                      
                }
                break;
                
            case Mode.GAME: 
                switch(val){
                    case '0':
                        game.chk_arr_res(Arrow.UP);
                        break; 
                        
                    case '1':
                        game.chk_arr_res(Arrow.LEFT);
                        break;   
                        
                    case '2':
                        game.chk_arr_res(Arrow.DOWN);
                        break;   
                        
                    case '3':
                        game.chk_arr_res(Arrow.RIGHT);
                        break;  
                    
                    case '4':
                        game.vol_chk = Volume.UP;
                        break;
                    
                    case '5':
                        game.vol_chk = Volume.LEFT;
                        break;
                        
                    case '7':
                        game.vol_chk = Volume.RIGHT;
                        break;
                }
                break;
                
            case Mode.RESULT:
                if(val == '8') {
                    result.leave();
                    mode.to_menu();
                    break;
                }
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
    text("FPS: " + int(frameRate), 100, 850);
}

PImage backgnd_intro, backgnd_game, backgnd_result,logo, bonus;
PImage vol_up, vol_left, vol_down, vol_right;
PImage arr_up, arr_left, arr_down, arr_right;
PImage arr_up_op, arr_left_op, arr_down_op, arr_right_op, arr_null_op;
PImage bad_img, normal_img, excellent_img, combo, score, accuracy;
PImage rank_d, rank_c, rank_b, rank_a, rank_s;
PFont comic;

void font_init() {
    comic = createFont("Comic Sans MS.ttf", 48);
    textFont(comic);
    textAlign(CENTER, CENTER);
}

void img_init() {
    try {
        imageMode(CENTER);
        bonus = loadImage("bonus.png");
        backgnd_intro = loadImage("background_intro.png");
        backgnd_game = loadImage("background_game.png"); 
        backgnd_result = loadImage("background_result.jpg");
        
        vol_up = loadImage("vol_up.png");
        vol_left = loadImage("vol_left.png");
        vol_down = loadImage("vol_down.png");
        vol_right = loadImage("vol_right.png");
        
        arr_up = loadImage("arr_up.png");
        arr_left = loadImage("arr_left.png");
        arr_down = loadImage("arr_down.png");
        arr_right = loadImage("arr_right.png");
        
        arr_up_op = loadImage("arr_up_op.png");
        arr_left_op = loadImage("arr_left_op.png");
        arr_down_op = loadImage("arr_down_op.png");
        arr_right_op = loadImage("arr_right_op.png");
        arr_null_op = loadImage("arr_null_op.png");
        
        bad_img = loadImage("bad.png");
        normal_img = loadImage("normal.png");
        excellent_img = loadImage("excellent.png");
        combo = loadImage("combo.png");
        score = loadImage("score.png");
        accuracy = loadImage("accuracy.png");
        
        rank_d = loadImage("D.png");
        rank_c = loadImage("C.png");
        rank_b = loadImage("B.png");
        rank_a = loadImage("A.png");
        rank_s = loadImage("S.png");
    }
    catch(Exception e) {
        println("Please check your png file integration");
    }
}

void draw_time() {
    if(game.start_time != 0) {
        fill(#FFFFFF);
        textSize(32);
        text("Time: " + str(millis() - game.start_time), 300, 850);
    }
}

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
}

void keyPressed() {
    switch(mode.mode) {
        case Mode.INTRO:
            if(key == '\n') {
                mode.to_menu();
                intro.leave();
            }
            break;
            
        case Mode.MENU:
            switch(keyCode){
                case UP:
                    menu.song_ptr = (menu.song_ptr + 1) % song_list.size();
                    break; 
                    
                case LEFT:
                    break;   
                    
                case DOWN:
                    menu.song_ptr = (menu.song_ptr - 1) % song_list.size();
                    if(menu.song_ptr < 0) {
                        menu.song_ptr += song_list.size();
                    }
                    break;   
                    
                case RIGHT:
                    break;        
            }
            
            switch(key) {
                case 'q':
                    mode.to_intro();
                    menu.leave();
                    break;
                                                   
                case '4':
                    beat.speed = Beat.MIDDLE;
                    break;
                    
                case '5':
                    beat.speed = Beat.FAST;
                    break;
                    
                case '7':
                    beat.speed = Beat.SLOW;
                    break;
                   
                case '\n':
                    mode.to_game();
                    menu.leave();
                    game = new Game();
                    break;
            } 
            break;
            
        case Mode.GAME:
            switch(keyCode){
                case UP:
                    game.chk_arr_res(Arrow.UP);
                    break; 
                    
                case LEFT:
                    game.chk_arr_res(Arrow.LEFT);
                    break;   
                    
                case DOWN:
                    game.chk_arr_res(Arrow.DOWN);
                    break;   
                    
                case RIGHT:
                    game.chk_arr_res(Arrow.RIGHT);
                    break;        
            }
            
            switch(key) {
                case 'q':
                    game.leave();
                    mode.to_result();
                    break;
                    
                case 'r':
                    game.retry();
                    break;
                               
                case '8':
                    game.vol_chk = Volume.UP;
                    break;
                    
                case '4':
                    game.vol_chk = Volume.LEFT;
                    break;
                    
                case '2':
                    game.vol_chk = Volume.DOWN;
                    break;
                    
                case '6':
                    game.vol_chk = Volume.RIGHT;
                    break;
                    
                case '\n':
                    break;
            } 
            break; 
        case Mode.RESULT:
            switch(key) {
                case 'q':
                result.leave();
                mode.to_menu();
                break;
            }
            break;
    }  
}

void setup() {   
    minim = new Minim(this);    
    mode = new Mode();
    intro = new Intro();
    menu = new Menu();  
    result = new Result();
    beat = new Beat();
    size(1600, 900, P3D);
    frameRate(80);   
    img_init();     
    font_init();
    port_init();       
}

void draw() {  //main function of this program        
    if(serial_flag) {
        read_port(); 
    }  
    switch(mode.mode){
        case Mode.INTRO:
            intro.draw();
            if(!intro.intro.isPlaying()) {
                intro.play();
            }
            break;
            
        case Mode.MENU:
            menu.play();
            menu.draw();
            break;
         
        case Mode.GAME:
            if(game.start_time == 0) {
                game.start_time = millis();
            }
            if(!game.song.isPlaying()) {
                game.play(); 
            }
            game.update_queue(); 
            game.move_beat();         
            game.draw(); 
            values.draw();
            rank.draw();
            game.chk_end();
            draw_time();
            game.bonus_chk();
            break;    
        
        case Mode.RESULT:
            result.play();
            result.draw();
            break;
    }
    draw_fps();
}
