defmodule Othello do
  @board_size 8
  @initial_board List.duplicate(List.duplicate(:empty, @board_size), @board_size)

  defstruct board: @initial_board, current_player: :black

  def new_game do
    board = @initial_board
    |> put_initial_discs()

    %Othello{board: board}
  end

  defp put_initial_discs(board) do
    board
    |> put_disc(3, 3, :white)
    |> put_disc(3, 4, :black)
    |> put_disc(4, 3, :black)
    |> put_disc(4, 4, :white)
  end

  defp put_disc(board, row, col, color) do
    List.update_at(board, row, fn row_list ->
      List.update_at(row_list, col, fn _ -> color end)
    end)
  end

  def print_board(%Othello{board: board}) do
    # Print column headers
    IO.write "  "
    for col <- 0..(@board_size - 1) do
      IO.write "#{col} "
    end
    IO.puts ""

    # Print each row with row number
    for {row, index} <- Enum.with_index(board) do
      IO.write "#{index} "
      for cell <- row do
        IO.write cell_to_char(cell)
        IO.write " "
      end
      IO.puts ""
    end
  end

  defp cell_to_char(:empty), do: "."
  defp cell_to_char(:black), do: "B"
  defp cell_to_char(:white), do: "W"

  def play_turn(game) do
    IO.puts "Player #{color_to_char(game.current_player)}, enter your move (row,col):"
    input = IO.gets("> ")
    case parse_input(input) do
      {:ok, {row, col}} ->
        if valid_move?(game.board, row, col, game.current_player) do
          game = make_move(game, row, col)
          game = %Othello{game | current_player: next_player(game.current_player)}
          print_board(game)
          game
        else
          IO.puts "Invalid move. Please enter a valid move."
          play_turn(game)
        end
      :error ->
        IO.puts "Invalid input. Please enter a valid move."
        play_turn(game)
    end
  end

  defp parse_input(input) do
    case String.trim(input) |> String.split(",") do
      [row_str, col_str] ->
        with {row, ""} <- Integer.parse(row_str),
             {col, ""} <- Integer.parse(col_str),
             true <- valid_position?(row, col) do
          {:ok, {row, col}}
        else
          _ -> :error
        end
      _ -> :error
    end
  end

  defp valid_position?(row, col) do
    row in 0..(@board_size - 1) and col in 0..(@board_size - 1)
  end

  defp valid_move?(board, row, col, player) do
    if valid_position?(row, col) and board |> Enum.at(row) |> Enum.at(col) == :empty do
      can_flip?(board, row, col, player)
    else
      false
    end
  end

  defp can_flip?(board, row, col, player) do
    directions = [
      {-1, 0}, {1, 0}, {0, -1}, {0, 1},
      {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    ]
    Enum.any?(directions, fn {dr, dc} ->
      check_direction(board, row + dr, col + dc, dr, dc, player, false)
    end)
  end

  defp check_direction(_board, _row, _col, _dr, _dc, _player, true), do: true
  defp check_direction(board, row, col, dr, dc, player, false) do
    if valid_position?(row, col) do
      case board |> Enum.at(row) |> Enum.at(col) do
        ^player -> false
        :empty -> false
        _other -> check_direction(board, row + dr, col + dc, dr, dc, player, true)
      end
    else
      false
    end
  end
  defp check_direction(board, row, col, dr, dc, player, true) do
    if valid_position?(row, col) do
      case board |> Enum.at(row) |> Enum.at(col) do
        ^player -> true
        :empty -> false
        _other -> check_direction(board, row + dr, col + dc, dr, dc, player, true)
      end
    else
      false
    end
  end

  defp color_to_char(:black), do: "B"
  defp color_to_char(:white), do: "W"

  defp next_player(:black), do: :white
  defp next_player(:white), do: :black

  defp make_move(game, row, col) do
    board = put_disc(game.board, row, col, game.current_player)
    board = flip_discs(board, row, col, game.current_player)
    %Othello{game | board: board}
  end

  defp flip_discs(board, row, col, player) do
    directions = [
      {-1, 0}, {1, 0}, {0, -1}, {0, 1},
      {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    ]
    Enum.reduce(directions, board, fn {dr, dc}, acc_board ->
      flip_in_direction(acc_board, row + dr, col + dc, dr, dc, player, [])
    end)
  end

  defp flip_in_direction(board, row, col, dr, dc, player, discs_to_flip) do
    if valid_position?(row, col) do
      case board |> Enum.at(row) |> Enum.at(col) do
        ^player -> Enum.reduce(discs_to_flip, board, fn {r, c}, acc ->
                      put_disc(acc, r, c, player)
                    end)
        :empty -> board
        _other -> flip_in_direction(board, row + dr, col + dc, dr, dc, player, [{row, col} | discs_to_flip])
      end
    else
      board
    end
  end

  def start_game do
    game = new_game()
    print_board(game)
    game_loop(game)
  end

  defp game_loop(game) do
    game = play_turn(game)
    game_loop(game)
  end
end

# Start the game
Othello.start_game()
