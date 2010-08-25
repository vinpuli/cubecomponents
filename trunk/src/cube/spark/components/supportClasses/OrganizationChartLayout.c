#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "AS3.h"

typedef enum { FALSE, TRUE } boolean;
typedef struct {
	float xVal;
	float yVal;
} float2;
typedef struct {
	int childLen;
	int* children;
} processedNode;

const int _INTSIZE = sizeof(int);
const int _FLOATSIZE = sizeof(float);
const int _BOOLEANSIZE = sizeof(boolean);
processedNode **_processedNodes = NULL;
int _data_len, _originator;
double _horizontalPadding, _verticalPadding;
boolean _initialized = FALSE;
boolean _hasOriginator = FALSE;
boolean _hasProcessedNodes = FALSE;

int* _data_id;
int* _data_ownerId;
int* _data_memPos_id;
int* _data_visibleItems;
int* _data_ownerVisibleItems;
int* _data_state;
int* _data_collapsed;
int* _data_visible;
int* _data_hasChildren;
float* _data_minimizedWidth;
float* _data_minimizedHeight;
float* _data_normalWidth;
float* _data_normalHeight;
float* _data_maximizedWidth;
float* _data_maximizedHeight;
float* _data_xPos;
float* _data_yPos;
float* _data_measuredWidth;
float* _data_measuredHeight;

static inline int findOriginator() {
	int i, ownerId;
	for (i=0; i<_data_len; i++) {
		ownerId = _data_ownerId[i];
		if (ownerId < 0) {
			return i;
		}
	}
	return -1;
}

static inline void reset() {
	int i, maxId;
	_hasProcessedNodes = FALSE;
	maxId = 0;
	if (_initialized) {
		for (i=0; i<_data_len; i++) {
			maxId = (_data_id[i] > maxId) ? _data_id[i] : maxId;
		}
		free(_data_memPos_id);
		_data_memPos_id = calloc(maxId, _INTSIZE);
		for (i=0; i<_data_len; i++) {
			if (!_hasProcessedNodes) {
				free(_processedNodes[i]);
				_processedNodes[i] = (processedNode *)malloc(sizeof(processedNode));
			}
			_data_hasChildren[i] = 0;
			_data_visible[i] = 0;
			_data_xPos[i] = 0;
			_data_yPos[i] = 0;
			_data_memPos_id[_data_id[i]] = i;
		}
	}
}

AS3_Val flushBuffers(void* self, AS3_Val args) {
	if (_initialized) {
		fprintf(stderr, "***DEBUG*** Flushed");
		free(_data_id);
		free(_data_ownerId);
		free(_data_minimizedWidth);
		free(_data_minimizedHeight);
		free(_data_normalWidth);
		free(_data_normalHeight);
		free(_data_maximizedWidth);
		free(_data_maximizedHeight);
		free(_data_state);
		free(_data_collapsed);
		free(_data_xPos);
		free(_data_yPos);
		free(_data_measuredWidth);
		free(_data_measuredHeight);
		free(_data_visibleItems);
		free(_data_ownerVisibleItems);
		free(_data_visible);
		free(_data_hasChildren);
		_hasOriginator = _initialized = FALSE;
	}
	return AS3_Int(0);
}

AS3_Val initializeBuffers(void* self, AS3_Val args) {
	AS3_Val retVal;
	if (!_initialized) {
		AS3_ArrayValue(args, "IntType", &_data_len);
		fprintf(stderr, "***DEBUG*** Creating memory for %d items", _data_len);
		_data_id = calloc(_data_len, _INTSIZE);
		_data_ownerId = calloc(_data_len, _INTSIZE);
		_data_minimizedWidth = calloc(_data_len, _FLOATSIZE);
		_data_minimizedHeight = calloc(_data_len, _FLOATSIZE);
		_data_normalWidth = calloc(_data_len, _FLOATSIZE);
		_data_normalHeight = calloc(_data_len, _FLOATSIZE);
		_data_maximizedWidth = calloc(_data_len, _FLOATSIZE);
		_data_maximizedHeight = calloc(_data_len, _FLOATSIZE);
		_data_state = calloc(_data_len, _INTSIZE);
		_data_collapsed = calloc(_data_len, _INTSIZE);
		_data_hasChildren = calloc(_data_len, _INTSIZE);
		_data_xPos = calloc(_data_len, _FLOATSIZE);
		_data_yPos = calloc(_data_len, _FLOATSIZE);
		_data_measuredWidth = calloc(_data_len, _FLOATSIZE);
		_data_measuredHeight = calloc(_data_len, _FLOATSIZE);
		_data_visibleItems = calloc(_data_len, _INTSIZE);
		_data_ownerVisibleItems = calloc(_data_len, _INTSIZE);
		_data_visible = calloc(_data_len, _INTSIZE);
		_processedNodes = (processedNode **)realloc(_processedNodes, _data_len * sizeof(processedNode *));
		retVal = AS3_Int(_data_len*7*_INTSIZE+_data_len*10*_FLOATSIZE);
		reset();
		_initialized = TRUE;
	} else {
		retVal = AS3_Int(0);
	}
	return retVal;
}

AS3_Val getDataPointerForHasChildren(void* self, AS3_Val args) {
	return AS3_Ptr(_data_hasChildren);
}

AS3_Val getDataPointerForVisibleItems(void* self, AS3_Val args) {
	return AS3_Ptr(_data_visibleItems);
}

AS3_Val getDataPointerForOwnerVisibleItems(void* self, AS3_Val args) {
	return AS3_Ptr(_data_ownerVisibleItems);
}

AS3_Val getDataPointerForId(void* self, AS3_Val args) {
	return AS3_Ptr(_data_id);
}

AS3_Val getDataPointerForOwnerId(void* self, AS3_Val args) {
	return AS3_Ptr(_data_ownerId);
}

AS3_Val getDataPointerForMinimizedWidth(void* self, AS3_Val args) {
	return AS3_Ptr(_data_minimizedWidth);
}

AS3_Val getDataPointerForMinimizedHeight(void* self, AS3_Val args) {
	return AS3_Ptr(_data_minimizedHeight);
}

AS3_Val getDataPointerForNormalWidth(void* self, AS3_Val args) {
	return AS3_Ptr(_data_normalWidth);
}

AS3_Val getDataPointerForNormalHeight(void* self, AS3_Val args) {
	return AS3_Ptr(_data_normalHeight);
}

AS3_Val getDataPointerForMaximizedWidth(void* self, AS3_Val args) {
	return AS3_Ptr(_data_maximizedWidth);
}

AS3_Val getDataPointerForMaximizedHeight(void* self, AS3_Val args) {
	return AS3_Ptr(_data_maximizedHeight);
}

AS3_Val getDataPointerForState(void* self, AS3_Val args) {
	return AS3_Ptr(_data_state);
}

AS3_Val getDataPointerForCollapsed(void* self, AS3_Val args) {
	return AS3_Ptr(_data_collapsed);
}

AS3_Val getDataPointerForXPos(void* self, AS3_Val args) {
	return AS3_Ptr(_data_xPos);
}

AS3_Val getDataPointerForYPos(void* self, AS3_Val args) {
	return AS3_Ptr(_data_yPos);
}

static inline int getMemPos(int id) {
	int i;
	for (i=0; i<_data_len; i++) {
		if (_data_id[i] == id) { return i; }
	}
	return 0;
}

static inline float getItemSize(int memPos, boolean widthOrHeight) {
	if (_data_state[memPos] == 0) { return widthOrHeight ? _data_minimizedWidth[memPos] : _data_minimizedHeight[memPos]; }
	if (_data_state[memPos] == 1) { return widthOrHeight ? _data_normalWidth[memPos] : _data_normalHeight[memPos]; }
	if (_data_state[memPos] == 2) { return widthOrHeight ? _data_maximizedWidth[memPos] : _data_maximizedHeight[memPos]; }
	return 0;
}

static inline float2 map(int *memPos) {
	boolean hasChildren;
	int i, childMemPos, startPos, originatorId, childIndex;
	float offset, offsetX, offsetY, tw, th, firstChildOffset, uw, dw, dh;
	float childrenMaxWidth = 0;
	float childrenMaxHeight = 0;
	int children[1000];
	float2 mapVal, returnVal;
	uw = 0;
	dw = getItemSize(*memPos, TRUE);
	dh = getItemSize(*memPos, FALSE);
	hasChildren = FALSE;
	childIndex = 0;
	_data_visible[*memPos] = 1;
	if (_data_collapsed[*memPos] == 0) {
		if (_hasProcessedNodes) {
			childIndex = _processedNodes[*memPos]->childLen;
			for (i=0; i<childIndex; i++) {
				childMemPos = _processedNodes[*memPos]->children[i];
				mapVal = map(&childMemPos);
				_data_measuredWidth[childMemPos] = mapVal.xVal;
				_data_measuredHeight[childMemPos] = mapVal.yVal;
				childrenMaxWidth += mapVal.xVal;
				if (mapVal.yVal > childrenMaxHeight) {
					childrenMaxHeight = mapVal.yVal;
				}
				hasChildren = TRUE;
			}
		} else {
			originatorId = _data_id[*memPos];
			startPos = *memPos+1;
			childIndex = 0;
			for (i=startPos; i<_data_len; i++) {
				if (_data_ownerId[i] == originatorId) {
					children[childIndex++] = i;
					mapVal = map(&i);
					_data_measuredWidth[i] = mapVal.xVal;
					_data_measuredHeight[i] = mapVal.yVal;
					childrenMaxWidth += mapVal.xVal;
					if (mapVal.yVal > childrenMaxHeight) {
						childrenMaxHeight = mapVal.yVal;
					}
					hasChildren = TRUE;
				} else if (hasChildren) { break; }
			}
			_processedNodes[*memPos]->childLen = childIndex;
			_processedNodes[*memPos]->children = children;
		}
		if (hasChildren) {
			childrenMaxWidth += _horizontalPadding*(childIndex-1);
		}
	}
	offset = (dw-childrenMaxWidth)*.5;
	offsetX = _data_xPos[*memPos]+offset;
	offsetY = _data_yPos[*memPos]+dh;
	for (i=0; i<childIndex; i++) {
		childMemPos = children[i];
		firstChildOffset = (_data_measuredWidth[childMemPos]-getItemSize(childMemPos, TRUE))*.5;
		tw = _data_measuredWidth[childMemPos];
		th = _data_measuredHeight[childMemPos];
		_data_xPos[childMemPos] += (float)(offsetX+firstChildOffset+uw);
		_data_yPos[childMemPos] = (float)(offsetY+(childrenMaxHeight-th)*.5+_verticalPadding);
		uw += tw+_horizontalPadding;
	}
	if (!hasChildren) {
		_data_yPos[*memPos] += _verticalPadding;
	}
	if (hasChildren) {
		returnVal.xVal = (dw > childrenMaxWidth) ? dw : childrenMaxWidth;
		returnVal.yVal = (dh > childrenMaxHeight) ? dh : childrenMaxHeight;
	} else {
		returnVal.xVal = dw;
		returnVal.yVal = dh;
	}
	_data_hasChildren[*memPos] = (_processedNodes[*memPos]->childLen > 0) ? 1 : 0;
	return returnVal;
}

static inline float normalize(float dx) {
	int i, owner;
	float maxHeight = 0;
	float itemHeight;
	for (i=0; i<_data_len; i++) {
		owner = _data_memPos_id[_data_ownerId[i]];
		if (owner >= 0) {
			_data_xPos[i] += _data_xPos[owner];
			_data_yPos[i] += _data_yPos[owner];
		}
		itemHeight = getItemSize(i, FALSE);
		maxHeight = (maxHeight < (_data_yPos[i]+itemHeight)) ? (_data_yPos[i]+itemHeight) : maxHeight;
	}
	for (i=0; i<_data_len; i++) {
		_data_xPos[i] += dx;
	}
	return maxHeight;
}

static inline boolean isWithinVisibleArea(int memPos, double entryPointX, double entryPointY, double entryPointWidth, double entryPointHeight) {
	if (memPos == _originator) { return TRUE; }
	if (_data_visible[memPos] == 0) { return FALSE; }
	const float dx = _data_measuredWidth[memPos];
	const float dy = entryPointHeight+getItemSize(memPos, FALSE);
	const float tx = _data_xPos[memPos]+getItemSize(memPos, TRUE)*.5-dx*.5;
	const float ty = _data_yPos[memPos];
	const float ux = tx+dx;
	const float uy = ty+dy;
	if (ux >= entryPointX && tx < (entryPointX+entryPointWidth) &&
		uy >= entryPointY && ty < (entryPointY+entryPointHeight)) {
		return TRUE;
	}
	return FALSE;
}

AS3_Val calculate(void* self, AS3_Val args) {
	float totalHeight;
	int i, j, k, updateType, ownerMemPos;
	double entryPointX, entryPointY, entryPointWidth, entryPointHeight;
	boolean hasMatch;
	AS3_ArrayValue(args, "DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, IntType", &_horizontalPadding, &_verticalPadding, &entryPointX, &entryPointY, &entryPointWidth, &entryPointHeight, &updateType);
	float2 totalSize;
	j = 0;
	if (!_hasOriginator) {
		_originator = findOriginator();
		_hasOriginator = TRUE;
	}
	if (updateType > 0) {
		reset();
		totalSize = map(&_originator);
		totalHeight = normalize(totalSize.xVal*.5-getItemSize(_originator, TRUE)*.5);
		//totalHeight += getItemSize(_originator, FALSE);
	}
	_hasProcessedNodes = TRUE;
	for (i=0; i<_data_len; i++) {
		if (_data_visible[i]) {
			ownerMemPos = _data_memPos_id[_data_ownerId[i]];
			if (isWithinVisibleArea(ownerMemPos, entryPointX, entryPointY, entryPointWidth, entryPointHeight)) {
				_data_visibleItems[j] = i;
				_data_ownerVisibleItems[j] = ownerMemPos;
				ownerMemPos = _data_memPos_id[_data_ownerId[ownerMemPos]];
				j++;
				if (!isWithinVisibleArea(ownerMemPos, entryPointX, entryPointY, entryPointWidth, entryPointHeight)) {
					k = 0;
					hasMatch = FALSE;
					for (k=0; k<j; k++) {
						if (_data_visibleItems[k] == ownerMemPos) {
							hasMatch = TRUE;
							break;
						}
					}
					if (!hasMatch) {
						_data_visibleItems[j] = ownerMemPos;
						_data_ownerVisibleItems[j] = -1;
						j++;
					}
				}
			}
		}
	}
	return AS3_Array("DoubleType, DoubleType, IntType", totalSize.xVal, totalHeight, j);
}

int main() {
	AS3_Val flushBuffersVal = AS3_Function(NULL, flushBuffers);
	AS3_Val initializeBuffersVal = AS3_Function(NULL, initializeBuffers);
	AS3_Val getDataPointerForHasChildrenVal = AS3_Function(NULL, getDataPointerForHasChildren);
	AS3_Val getDataPointerForVisibleItemsVal = AS3_Function(NULL, getDataPointerForVisibleItems);
	AS3_Val getDataPointerForOwnerVisibleItemsVal = AS3_Function(NULL, getDataPointerForOwnerVisibleItems);
	AS3_Val getDataPointerForIdVal = AS3_Function(NULL, getDataPointerForId);
	AS3_Val getDataPointerForOwnerIdVal = AS3_Function(NULL, getDataPointerForOwnerId);
	AS3_Val getDataPointerForMinimizedWidthVal = AS3_Function(NULL, getDataPointerForMinimizedWidth);
	AS3_Val getDataPointerForMinimizedHeightVal = AS3_Function(NULL, getDataPointerForMinimizedHeight);
	AS3_Val getDataPointerForNormalWidthVal = AS3_Function(NULL, getDataPointerForNormalWidth);
	AS3_Val getDataPointerForNormalHeightVal = AS3_Function(NULL, getDataPointerForNormalHeight);
	AS3_Val getDataPointerForMaximizedWidthVal = AS3_Function(NULL, getDataPointerForMaximizedWidth);
	AS3_Val getDataPointerForMaximizedHeightVal = AS3_Function(NULL, getDataPointerForMaximizedHeight);
	AS3_Val getDataPointerForStateVal = AS3_Function(NULL, getDataPointerForState);
	AS3_Val getDataPointerForCollapsedVal = AS3_Function(NULL, getDataPointerForCollapsed);
	AS3_Val getDataPointerForXPosVal = AS3_Function(NULL, getDataPointerForXPos);
	AS3_Val getDataPointerForYPosVal = AS3_Function(NULL, getDataPointerForYPos);
	AS3_Val calculateVal = AS3_Function(NULL, calculate);
    AS3_Val result = AS3_Object(
    	"flushBuffers:AS3ValType, initializeBuffers: AS3ValType, getDataPointerForHasChildren:AS3ValType, getDataPointerForVisibleItems:AS3ValType, getDataPointerForOwnerVisibleItems:AS3ValType, getDataPointerForId: AS3ValType, getDataPointerForOwnerId: AS3ValType, getDataPointerForMinimizedWidth: AS3ValType, getDataPointerForMinimizedHeight: AS3ValType, getDataPointerForNormalWidth: AS3ValType, getDataPointerForNormalHeight: AS3ValType, getDataPointerForMaximizedWidth: AS3ValType, getDataPointerForMaximizedHeight: AS3ValType, getDataPointerForState: AS3ValType, getDataPointerForCollapsed: AS3ValType, getDataPointerForXPos: AS3ValType, getDataPointerForYPos: AS3ValType, calculate: AS3ValType",
    	flushBuffersVal, initializeBuffersVal, getDataPointerForHasChildrenVal, getDataPointerForVisibleItemsVal, getDataPointerForOwnerVisibleItemsVal, getDataPointerForIdVal, getDataPointerForOwnerIdVal, getDataPointerForMinimizedWidthVal, getDataPointerForMinimizedHeightVal, getDataPointerForNormalWidthVal, getDataPointerForNormalHeightVal, getDataPointerForMaximizedWidthVal, getDataPointerForMaximizedHeightVal, getDataPointerForStateVal, getDataPointerForCollapsedVal, getDataPointerForXPosVal, getDataPointerForYPosVal, calculateVal);
    AS3_Release(flushBuffersVal);
    AS3_Release(initializeBuffersVal);
    AS3_Release(getDataPointerForHasChildrenVal);
    AS3_Release(getDataPointerForVisibleItemsVal);
    AS3_Release(getDataPointerForOwnerVisibleItemsVal);
    AS3_Release(getDataPointerForIdVal);
    AS3_Release(getDataPointerForOwnerIdVal);
    AS3_Release(getDataPointerForMinimizedWidthVal);
    AS3_Release(getDataPointerForMinimizedHeightVal);
    AS3_Release(getDataPointerForNormalWidthVal);
    AS3_Release(getDataPointerForNormalHeightVal);
    AS3_Release(getDataPointerForMaximizedWidthVal);
    AS3_Release(getDataPointerForMaximizedHeightVal);
    AS3_Release(getDataPointerForStateVal);
    AS3_Release(getDataPointerForCollapsedVal);
    AS3_Release(getDataPointerForXPosVal);
    AS3_Release(getDataPointerForYPosVal);
    AS3_Release(calculateVal);
    AS3_LibInit(result);
    return 0;
}
