class TicTacToeController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def checkToken(token, expected)
    return token && token == expected
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
                              :attachments => [ existing.state ] }
      else
        return render json: { :text => 'The current game is ongoing between ' + existing.player1 + ' and ' + existing.player2 + '. ' + existing.next + '\'s move',
                              :attachments => [ existing.state ] }
      end
    end

    return render json: { :text => 'No games in this channel.' }
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
