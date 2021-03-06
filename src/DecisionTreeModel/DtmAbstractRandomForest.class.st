Class {
	#name : #DtmAbstractRandomForest,
	#superclass : #Object,
	#instVars : [
		'trees',
		'minSizeForSplit',
		'maxDepth',
		'numberOfTrees',
		'sizeRatioForBoostrapping'
	],
	#category : #DecisionTreeModel
}

{ #category : #bagging }
DtmAbstractRandomForest >> bootstrap: aDataset [
	"Select random examples from dataset WITH replacement (allows repeated examples)"
	| randomIndices| 
	randomIndices := (1 to: (self bootstrapSize: aDataset)) collect: [ :each |  
		(1 to: aDataset size) atRandom. 
	].
	^ aDataset rowsAt: randomIndices
]

{ #category : #bagging }
DtmAbstractRandomForest >> bootstrapSize: aDataset [
	"Returns the size for the random sampling.
	Note that since the sampling is done with replacement
	even while using the size of the whole dataset it is expected that 
	each bootstrap will have ~63.2% unique examples, the rest being duplicates."
	^ aDataset size * sizeRatioForBoostrapping
]

{ #category : #classification }
DtmAbstractRandomForest >> decisionFor: anObject [
	| decisions |
	decisions := trees collect: [ : each | each decisionFor: anObject ].
	^ self voting: decisions.
]

{ #category : #classification }
DtmAbstractRandomForest >> decisionsForAll: aDataset [
	^ aDataset asArrayOfRows collect: [ :row | self decisionFor: row ].
]

{ #category : #bagging }
DtmAbstractRandomForest >> featureSubsetSize: aDataset [
	"Specify a number of features that is considerably less than the original size
	It is usual practice to use the square root of the original amount of features"
	^ aDataset features size sqrtFloor 
]

{ #category : #api }
DtmAbstractRandomForest >> fit: aDataset [
	| tree randomSubset |
	trees := (1 to: numberOfTrees) collect: [ :each |
		tree := self treeClass new 
				maxDepth: maxDepth; 
				minSizeForSplit: minSizeForSplit;
				yourself. 
		randomSubset := self bootstrap: aDataset.
		randomSubset features: (self randomFeaturesOf: aDataset).
		tree 
			fit: randomSubset; 
			yourself.
	]
]

{ #category : #initialization }
DtmAbstractRandomForest >> initialize [
	super initialize.
	numberOfTrees := 10.
	minSizeForSplit := 0.
	maxDepth := Float infinity.
	sizeRatioForBoostrapping := 1.
]

{ #category : #accessing }
DtmAbstractRandomForest >> maxDepth [
	^ maxDepth
]

{ #category : #accessing }
DtmAbstractRandomForest >> maxDepth: anObject [
	maxDepth := anObject
]

{ #category : #accessing }
DtmAbstractRandomForest >> minSizeForSplit [
	^ minSizeForSplit
]

{ #category : #accessing }
DtmAbstractRandomForest >> minSizeForSplit: anObject [
	minSizeForSplit := anObject
]

{ #category : #accessing }
DtmAbstractRandomForest >> numberOfTrees [
	^ numberOfTrees
]

{ #category : #accessing }
DtmAbstractRandomForest >> numberOfTrees: anObject [
	numberOfTrees := anObject
]

{ #category : #bagging }
DtmAbstractRandomForest >> randomFeaturesOf: aDataset [
	"Return random subset of the features"
	^ aDataset features shuffled first: (self featureSubsetSize: aDataset)
]

{ #category : #accessing }
DtmAbstractRandomForest >> sizeRatioForBoostrapping [
	^ sizeRatioForBoostrapping
]

{ #category : #accessing }
DtmAbstractRandomForest >> sizeRatioForBoostrapping: anObject [
	sizeRatioForBoostrapping := anObject
]

{ #category : #accessing }
DtmAbstractRandomForest >> treeClass [
	self subclassResponsibility 
]

{ #category : #classification }
DtmAbstractRandomForest >> voting: anArrayOfDecisions [
	"Specify how to mix the decisions of all the trees"
	self subclassResponsibility
]
