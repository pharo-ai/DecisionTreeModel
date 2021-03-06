Class {
	#name : #DtmMultiwayDecisionTreeTest,
	#superclass : #TestCase,
	#instVars : [
		'tennisDecisionTree'
	],
	#category : #'DecisionTree-Tests'
}

{ #category : #running }
DtmMultiwayDecisionTreeTest >> setUp [
	| overcastNode |
	super setUp.
	tennisDecisionTree := DtmMultiwayDecisionTree withCondition: [ :weather | weather at: #outlook].
	
	tennisDecisionTree at: #rain addChild: (DtmDecision withLabel: 'stay home').
	tennisDecisionTree at: #sunny addChild: (DtmDecision withLabel: 'play tennis').
	tennisDecisionTree at: #overcast addChild: (DtmMultiwayDecisionTree withCondition: [ :weather | weather at: #wind]).
	overcastNode := tennisDecisionTree childAt: #overcast.
	overcastNode at: #strong addChild: (DtmDecision withLabel: 'stay home').
	overcastNode at: #weak addChild: (DtmDecision withLabel: 'play tennis').
]

{ #category : #tests }
DtmMultiwayDecisionTreeTest >> testHeight [
	self assert: tennisDecisionTree height equals: 2
]

{ #category : #tests }
DtmMultiwayDecisionTreeTest >> testPlayTennisWhenOvercastAndWeakWind [

	| weather decision expected |	
	weather := { #outlook -> #overcast . #wind -> #weak} asDictionary.
	decision := tennisDecisionTree decisionFor: weather.
	expected := 'play tennis'.
	self assert: decision label equals: expected.
]

{ #category : #tests }
DtmMultiwayDecisionTreeTest >> testPlayTennisWhenSunny [

	| weather decision expected |	
	weather := { #outlook -> #sunny . #wind -> #strong} asDictionary.
	decision := tennisDecisionTree decisionFor: weather.
	expected := 'play tennis'.
	self assert: decision label equals: expected.
]

{ #category : #tests }
DtmMultiwayDecisionTreeTest >> testStayHomeWhenRainy [

	| weather decision expected |	
	weather := { #outlook -> #rain . #wind -> #weak} asDictionary.
	decision := tennisDecisionTree decisionFor: weather.
	expected := 'stay home'.
	self assert: decision label equals: expected.
]

{ #category : #tests }
DtmMultiwayDecisionTreeTest >> testWhyPlayTennisWhenOvercastAndWeakWind [

	| weather decision expected |	
	weather := { #outlook -> #overcast . #wind -> #weak} asDictionary.
	decision := tennisDecisionTree decisionFor: weather.
	expected := { tennisDecisionTree condition -> #overcast .
					  (tennisDecisionTree childAt: #overcast) condition -> #weak } asOrderedCollection.
	self assert: decision why equals: expected.
]
