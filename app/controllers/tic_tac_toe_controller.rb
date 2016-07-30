class TicTacToeController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def checkToken(token, expected)
    return token && token == expected
  end

  def unescapeJson(jsonObj)
    temp = JSON.generate(jsonObj)
    temp.gsub! '\\\\', '\\'
    return temp
  end

  def formatBoard(state)
    result = ''
    for i in 0..2
      # result += '['
      for j in 0..2
        result +=  case state[i * 3 + j]
                     when '0' then '[  _  ]'
                     when '1' then '[  X  ]'
                     when '2' then '[  O  ]'
                   end
      end
      # result += ''
      if i != 2
        result += '\n'
      end
    end
    return result
  end

  def checkWinner(state, player1, player2)

    for i in 0..2

      row_candidate = true
      column_candidate = true

      for j in 1..2

        # check rows
        if state[i * 3 + j] == '0' || state[i * 3 + j] != state[i * 3 + j - 1] then
          row_candidate = false
        elsif row_candidate && state[i * 3 + j] == state[i * 3 + j - 1] then
          if j == 2 then
            winner = if state[i * 3 + j] == '1' then player1 else player2 end
            return winner
          end
        end

        # check columns
        if state[j * 3 + i] == '0' || state[j * 3 + i] != state[(j - 1) * 3 + i] then
          column_candidate = false
        elsif column_candidate && state[j * 3 + i] == state[(j - 1) * 3 + i] then
          if j == 2 then
            winner = if state[j * 3 + i] == '1' then player1 else player2 end
            return winner
          end
        end
      end
    end

    if state[0] == state[4] && state[4] == state[8] && state[0] != '0' then
      winner = if state[0] == '1' then player1 else player2 end
      return winner
    end

    if state[2] == state[4] && state[4] == state[6] && state[2] != '0' then
      winner = if state[2] == '1' then player1 else player2 end
      return winner
    end

    return nil
  end

  def create
    if not checkToken(params['token'], 'YVyjszmysk7T8Cr299F5Tbb4') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end

    channel = params['channel_id']
    userName = params['user_name']
    text = params['text']
    if !userName || !text then
      return render json: { :text => 'Bad command. /newgame @username' }
    end

    existing = Board.find_by(:channel => channel)
    if existing then
      if existing.next then
        return render json: { :text => 'There is one game per channel at a time' }
      else
        existing.destroy
      end
    end

    opponent = /(@)(.*)/.match(text.strip)[2]
    newgame = Board.new(:channel => channel,
                        :player1 => userName,
                        :player2 => opponent,
                        :state => '000000000',
                        :next => userName)
    if newgame.save() then
      render json: { :response_type => 'in_channel', :text => 'New game created for ' + userName + ' and ' + opponent + '. @' + userName + '\'s move'}
    else
      render json: { :text => 'Some error happened, try again' }
    end
  end

  def get
    if not checkToken(params['token'], 'pqNgvumzhx5SO6VWqd8YeShN') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end
    channel = params['channel_id']

    existing = Board.find_by(:channel => channel)
    if existing then
      if !existing.next then
        output = { :text => 'The current game is complete between ' + existing.player1 + ' and ' + existing.player2,
                              :attachments => [ :text => formatBoard(existing.state) ] }
        return render json: unescapeJson(output)
      else
        output = { :text => 'The current game is ongoing between ' + existing.player1 + ' and ' + existing.player2 + '. ' + existing.next + '\'s move',
                              :attachments => [ :text => formatBoard(existing.state) ] }
        return render json: unescapeJson(output)
      end
    end

    return render json: { :text => 'No games in this channel.' }
  end

  def move
    if not checkToken(params['token'], 'EKORPm7ibCmSLNMbVycwkR5t') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end
    channel = params['channel_id']
    userName = params['user_name']
    text = params['text']
    if !userName || !text then
      return render json: { :text => 'Bad command. /move x y' }
    end

    existing = Board.find_by(:channel => channel)
    if existing then
      if !existing.next then
        return render json: { :text => 'The current game is complete between ' + existing.player1 + ' and ' + existing.player2,
                              :attachments => [ :text => formatBoard(existing.state) ] }
      elsif userName != existing.next then
        return render json: { :text => 'It is not yet your move. ' + existing.next + '\'s move',
                              :attachments => [ :text => formatBoard(existing.state) ] }
      end
    end

    coord = text.split
    x = coord[0].to_i
    y = coord[1].to_i

    if x < 0 || x > 2 || y < 0 || y > 2 || existing.state[x * 3 + y] != '0' then
      return render json: { :text => 'Bad command. x y are rows and columns of the grid, must be between 0, 1 and 2. The grid must be currently empty' }
    end

    existing.state[ x * 3 + y ] = if existing.next == existing.player1 then '1' else '2' end
    winner = checkWinner(existing.state, existing.player1, existing.player2)
    current = existing.next
    if winner then
      existing.next = nil
      if existing.save()
        return render json: { :response_type => 'in_channel',
                              :text => current + ' is the winner!',
                              :attachments => [ :text => formatBoard(existing.state) ] }
      end
    elsif !winner and !(existing.state.include? '0')
      existing.next = nil
      if existing.save()
        return render json: { :response_type => 'in_channel',
                              :text => current + ' made a move, but the game ended in a draw!',
                              :attachments => [ :text => formatBoard(existing.state) ] }
      end
    else
      existing.next = if current == existing.player1 then existing.player2 else existing.player1 end
      if existing.save()
        return render json: { :response_type => 'in_channel',
                              :text => current + ' made a move. ' + existing.next + ' you are up next!',
                              :attachments => [ :text => formatBoard(existing.state) ] }
      end
    end

    render json: { :text => 'Some error happened, try again' }
  end

  def del
    if not checkToken(params['token'], 'eaGsF48NxM8J9bqDyRew1vHD') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end

    channel = params['channel_id']
    existing = Board.find_by(:channel => channel)
    if existing then
      existing.destroy
      return render json: { :text => 'Removed the current game for the channel. It was between ' + existing.player1 + " and " + existing.player2 }
    end

    return render json: { :text => 'No ongoing game in the current channel' }
  end
end
