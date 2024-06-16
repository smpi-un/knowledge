class OthelloGame:
    def __init__(self):
        self.board = [[' ' for _ in range(8)] for _ in range(8)]
        self.board[3][3] = self.board[4][4] = 'W'
        self.board[3][4] = self.board[4][3] = 'B'
        self.current_turn = 'B'

    def print_board(self):
        print('  ' + ' '.join(map(str, range(8))))
        for i in range(8):
            print(str(i) + ' ' + ' '.join(self.board[i]))

    def is_valid_move(self, row, col):
        if self.board[row][col] != ' ':
            return False
        directions = [(-1, -1), (-1, 0), (-1, 1),
                      (0, -1),          (0, 1),
                      (1, -1), (1, 0), (1, 1)]
        for dr, dc in directions:
            r, c = row + dr, col + dc
            if self.is_on_board(r, c) and self.board[r][c] == self.opposite(self.current_turn):
                while self.is_on_board(r, c) and self.board[r][c] == self.opposite(self.current_turn):
                    r += dr
                    c += dc
                if self.is_on_board(r, c) and self.board[r][c] == self.current_turn:
                    return True
        return False

    def is_on_board(self, row, col):
        return 0 <= row < 8 and 0 <= col < 8

    def opposite(self, turn):
        return 'W' if turn == 'B' else 'B'

    def make_move(self, row, col):
        if not self.is_valid_move(row, col):
            return False
        self.board[row][col] = self.current_turn
        directions = [(-1, -1), (-1, 0), (-1, 1),
                      (0, -1),          (0, 1),
                      (1, -1), (1, 0), (1, 1)]
        for dr, dc in directions:
            r, c = row + dr, col + dc
            if self.is_on_board(r, c) and self.board[r][c] == self.opposite(self.current_turn):
                pieces_to_flip = []
                while self.is_on_board(r, c) and self.board[r][c] == self.opposite(self.current_turn):
                    pieces_to_flip.append((r, c))
                    r += dr
                    c += dc
                if self.is_on_board(r, c) and self.board[r][c] == self.current_turn:
                    for rr, cc in pieces_to_flip:
                        self.board[rr][cc] = self.current_turn
        self.current_turn = self.opposite(self.current_turn)
        return True

    def has_valid_moves(self):
        for row in range(8):
            for col in range(8):
                if self.is_valid_move(row, col):
                    return True
        return False

    def play_game(self):
        while True:
            self.print_board()
            print(f"Turn: {self.current_turn}")
            if not self.has_valid_moves():
                print(f"No valid moves for {self.current_turn}. Game over.")
                break
            row, col = map(int, input("Enter row and column (e.g., 3 4): ").split())
            if not self.make_move(row, col):
                print("Invalid move. Try again.")
            if not any(' ' in row for row in self.board):
                print("Board is full. Game over.")
                break

if __name__ == "__main__":
    game = OthelloGame()
    gagme.play_ame()
