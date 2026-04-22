package main

import (
	"errors"
	"strconv"
)

type Suit int

const (
	Spades Suit = iota
	Hearts
	Clubs
	Diamonds
)

type Card struct {
	name  string
	suit  Suit
	value int
}

func newCard(suit Suit, value int) Card {
	var letter = "S"
	if suit == 1 {
		letter = "H"
	}
	if suit == 2 {
		letter = "C"
	}
	if suit == 3 {
		letter = "D"
	}

	return Card{
		name:  letter + "_" + strconv.Itoa(value),
		suit:  suit,
		value: value,
	}
}

func newDeck() [52]Card {
	var newDeck = [52]Card{}
	for i := range 4 {
		for j := 2; j <= 14; j++ {
			newDeck[(i*13)+j-2] = newCard(Suit(i), j)
		}
	}
	return newDeck
}

func getCardByName(name string) (Card, error) {
	var deck = newDeck()
	for _, c := range deck {
		if c.name == name {
			return c, nil
		}
	}

	return Card{}, errors.New("invalid card")
}
