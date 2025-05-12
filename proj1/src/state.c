#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t *state, unsigned int snum);
static char next_square(game_state_t *state, unsigned int snum);
static void update_tail(game_state_t *state, unsigned int snum);
static void update_head(game_state_t *state, unsigned int snum);

/* Task 1 */
game_state_t *create_default_state() {
  game_state_t *new = (game_state_t*)malloc(sizeof(game_state_t));
  if(new == NULL){
    exit(1);
  }
  new->num_rows = 18;
  new->board = (char**)malloc((new->num_rows + 1) * sizeof(char*));
  if(new->board == NULL){
    printf("alloc memory failed!");
    free(new);
    exit(1);
  }
  for(int i = 0; i < new->num_rows; i++){
    new->board[i] = (char*)malloc((20 + 1) * sizeof(char));
    if(new->board[i] == NULL){
      printf("alloc memory failed!");
      free(new);
      exit(1);
    }
    if(i == 0 || i == new->num_rows - 1){
      strcpy(new->board[i],"####################"); 
    }else if(i == 2){
      strcpy(new->board[i],"# d>D    *         #");
    }else{
      strcpy(new->board[i],"#                  #");
    }
  }
  new->num_snakes = 1;
  new->snakes = (snake_t*)malloc((new->num_snakes) * sizeof(snake_t));
  if(new->snakes == NULL){
    printf("alloc memory failed!");
    free(new);
    exit(1);
  }
  new->snakes->live = true;
  new->snakes->tail_col = 2;
  new->snakes->tail_row = 2;
  new->snakes->head_col = 4;
  new->snakes->head_row = 2;
  return new;
}

/* Task 2 */
void free_state(game_state_t *state) {
  unsigned int num_rows = state->num_rows;
  for(int i = 0; i < num_rows; i++){
    free(state->board[i]);
  }
  free(state->board);
  free(state->snakes);
  free(state);
}

/* Task 3 */
void print_board(game_state_t *state, FILE *fp) {
  // TODO: Implement this function.
  if(state == NULL || state->board==NULL){
    exit(1);
  }
  for(unsigned int i = 0; i < state->num_rows; i++){
    fprintf(fp, "%s\n", state->board[i]);
  }
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t *state, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t *state, unsigned int row, unsigned int col) { return state->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  if(c == 'w' || c == 'a' || c == 's' || c == 'd'){
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  if(c == 'W' || c == 'S' || c == 'A' || c == 'D' || c == 'x'){
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  if(c == 'w' || c == 'a' || c == 's' || c == 'd' || 
    c == '^' || c == '<' || c == 'v' || c == '>' ||
    c == 'W' || c == 'A' || c== 'S' || c == 'D' ||
    c == 'x'){
      return true;
    }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  if( c == '^'){
    return 'w';
  }else if ( c == '>'){
    return 'd';
  }else if ( c == '<'){
    return 'a';
  }else if( c == 'v'){
    return 's';
  }else{
    return '?';
  }
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  if( c == 'W'){
    return '^';
  }else if( c == 'A'){
    return '<';
  }else if( c == 'D'){
    return '>';
  }else if( c == 'S'){
    return 'v';
  }else{
    return '?';
  }
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if( c == 'v' || c == 's' || c == 'S'){
    return cur_row + 1;
  }else if( c == '^' || c == 'w' || c == 'W'){
    return cur_row - 1;
  }else{
    return cur_row;
  }
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if ( c == '>' || c == 'd' || c == 'D'){
    return cur_col + 1;
  }else if( c == '<' || c == 'a' || c == 'A'){
    return cur_col - 1;
  }else{
    return cur_col;
  }
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t *state, unsigned int snum) {
  if(state == NULL || state->board==NULL || state->snakes == NULL){
    exit(1);
  }
  unsigned int head_row = state->snakes[snum].head_row;
  unsigned int head_col = state->snakes[snum].head_col;

  char head_char = state->board[head_row][head_col];

  unsigned int next_row = get_next_row(head_row, head_char);
  unsigned int next_col = get_next_col(head_col, head_char);
  if(next_row >= state->num_rows || next_col >= strlen(state->board[next_row])){
    return ' ';
  }
  return state->board[next_row][next_col];
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t *state, unsigned int snum) {
  if(state == NULL || state->board==NULL || state->snakes == NULL){
    exit(1);
  }
  unsigned int head_row = state->snakes[snum].head_row;
  unsigned int head_col = state->snakes[snum].head_col;

  char head_char = state->board[head_row][head_col];

  unsigned int next_row = get_next_row(head_row, head_char);
  unsigned int next_col = get_next_col(head_col, head_char);

  state->snakes->head_col = next_col;
  state->snakes->head_row = next_row;

  state->board[head_row][head_col] = head_to_body(head_char);
  state->board[next_row][next_col] = head_char;

}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t *state, unsigned int snum) {
  if(state == NULL || state->board==NULL || state->snakes == NULL){
    exit(1);
  }
  unsigned int tail_row = state->snakes[snum].tail_row;
  unsigned int tail_col = state->snakes[snum].tail_col;

  char tail_char = state->board[tail_row][tail_col];
  
  unsigned int next_row = get_next_row(tail_row, tail_char);
  unsigned int next_col = get_next_col(tail_col, tail_char);

  state->snakes->tail_col = next_col;
  state->snakes->tail_row = next_row;

  state->board[tail_row][tail_col] = ' ';
  state->board[next_row][next_col] = body_to_tail(state->board[next_row][next_col]);

}

/* Task 4.5 */
void update_state(game_state_t *state, int (*add_food)(game_state_t *state)) {
  if(state == NULL || state->board==NULL || state->snakes == NULL){
    exit(1);
  }
  unsigned int num_snakes = state->num_snakes;
  for(unsigned int i = 0; i < num_snakes; i++){
    if(state->snakes[i].live == true){
      char next_char = next_square(state, i);
      if(next_char == ' '){
        update_head(state, i);
        update_tail(state, i);
      }else if(next_char == '#'){
        state->snakes[i].live = false;
        state->board[state->snakes[i].head_row][state->snakes[i].head_col] = 'x';
      }else if(next_char == '*'){
        update_head(state, i);
        add_food(state);
      }else if(is_snake(next_char)){
        state->snakes[i].live = false;
        state->board[state->snakes[i].head_row][state->snakes[i].head_col] = 'x';
      }
    }
  }
  
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  if(fp == NULL){
    return NULL;
  }
  char *line = (char*)malloc(100 * sizeof(char));
  if(line == NULL){
    return NULL;
  }
  char *result = fgets(line, 100, fp);
  return result;
}

/* Tesk 5.2 */
game_state_t *load_board(FILE *fp) {
  if (fp == NULL) {
    return NULL;
  }
  game_state_t *state = malloc(sizeof(game_state_t));
  if (state == NULL) {
    return NULL;
  }
  unsigned int num_rows = 0;
  long pos = ftell(fp);  
  char buffer[100];
  while (fgets(buffer, sizeof(buffer), fp) != NULL) {
    num_rows++;
  }
  fseek(fp, pos, SEEK_SET);  
  
  state->num_rows = num_rows;
  state->board = malloc(num_rows * sizeof(char *));
  if (state->board == NULL) {
    free(state);
    return NULL;
  }
  
  for (unsigned int i = 0; i < num_rows; i++) {
    char *line = read_line(fp);
    if (line == NULL) {
      for (unsigned int j = 0; j < i; j++) {
        free(state->board[j]);
      }
      free(state->board);
      free(state);
      return NULL;
    }
    size_t len = strlen(line);
    if (len > 0 && line[len - 1] == '\n') {
      line[len - 1] = '\0';
    }
    state->board[i] = line;  
  }
  
  state->num_snakes = 0;
  state->snakes = NULL;
  
  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t *state, unsigned int snum) {
  // TODO: Implement this function
  unsigned int tail_row = state->snakes[snum].tail_row;
  unsigned int tail_col = state->snakes[snum].tail_col;

  char c = state->board[tail_row][tail_col];

  while(!is_head(c)){
    unsigned int next_row = get_next_row(tail_row, c);
    unsigned int next_col = get_next_col(tail_col, c);
    tail_row = next_row;
    tail_col = next_col;
    c = state->board[tail_row][tail_col];
  }
  state->snakes[snum].head_row = tail_row;
  state->snakes[snum].head_col = tail_col;
}

/* Task 6.2 */
game_state_t *initialize_snakes(game_state_t *state) {
  // TODO: Implement this function.
  if(state == NULL || state->board == NULL){
    return NULL;
  }

  unsigned int num_snakes = 0;
  for(unsigned int i = 0; i < state->num_rows; i++){
    for(unsigned int j = 0; j < strlen(state->board[i]); j++){
      if(is_tail(state->board[i][j])){
        num_snakes++;
      }
    }
  }
  if(num_snakes == 0){
    state->snakes = 0;
    state->snakes = NULL;
    return state;
  }

  state->num_snakes = num_snakes;
  state->snakes = (snake_t*)malloc(num_snakes * sizeof(snake_t));
  if(state->snakes == NULL){
    return NULL;
  }
  unsigned int snakeIdx = 0;
  for(unsigned int i = 0; i < state->num_rows; i++){
    for(unsigned int j = 0; j < strlen(state->board[i]); j++){
      if(is_tail(state->board[i][j])){
        state->snakes[snakeIdx].tail_col = j;
        state->snakes[snakeIdx].tail_row = i;
        find_head(state, snakeIdx);
        snakeIdx++;
      }
    }
  }

  return state;
}
