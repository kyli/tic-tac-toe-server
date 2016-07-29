class TicTacToeController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def checkToken(token, expected)
    return token && token == expected
  end

  def formatBoard(board)
    state = board.state
    result = ''
    for i in 0..2
      result += '['
      for j in 0..2
        result +=  case state[i * 3 + j]
                     when '0' then ' _ '
                     when '1' then ' X '
                     when '2' then ' O '
                   end
      end
      result += ']'
      if i != 2
        result += ', '
      end
    end
    return result
  end

  def checkWinner(board)
    winner = nil
    state = board.state

    # for i in 0..2
    #
    #   candidate =
    #
    #   for j in 1..2
    #     if state[i * 3 + j] == '0' then
    #       break
    #     elsif
    #
    #     end
    #
    #
    #   end
    # end

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
      render json: { :text => 'Something error happened, try again' }
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
        return render json: { :text => 'The current game is complete between ' + existing.player1 + ' and ' + existing.player2,
                              :attachments => [ :text => existing.state ] }
      else
        return render json: { :text => 'The current game is ongoing between ' + existing.player1 + ' and ' + existing.player2 + '. ' + existing.next + '\'s move',
                              :attachments => [ :text => formatBoard(existing) ] }
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
                              :attachments => [ :text => existing.state ] }
      elsif userName != existing.next then
        return render json: { :text => 'It is not yet your move. ' + existing.next + '\'s move',
                              :attachments => [ :text => existing.state ] }
      end
    end

    coord = text.split
    x = coord[0].to_i
    y = coord[1].to_i

    if x < 0 || x > 2 || y < 0 || y > 2 || existing.state[x * 3 + y] != '0' then
      return render json: { :text => 'Bad command. x y are rows and columns of the grid, must be between 0, 1 and 2. The grid must be currently empty' }
    end

    existing.state[ x * 3 + y ] = if existing.next == existing.player1 then '1' else '2' end
    # winner = checkWinner(existing)


    return render json: { :text => existing.next + ' made a move.',
                          :attachments => [ :text => existing.state ] }
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
  end
end
