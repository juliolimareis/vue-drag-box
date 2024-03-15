<template>
  <div>
    <Navbar>
      <Button @click="() => addBox()">Add Box</Button>

      <span v-if="showMenu">
        <Button @click="addChildInSelectedBox">Add Child</Button>
        <Button :disabled="selectedBox?.parent?.draggable || !selectedBox?.boxes.length" @click="() => handleGroup()">{{ selectedBox?.draggable ? 'Ungroup' : 'Group'}}</Button>
        <Button class="bg-red-500 hover:bg-red-600" @click="() => removeBox(selectedBox)">Remove</Button>
        <Button class="bg-gray-500 hover:bg-gray-600" @click="showDebug = !showDebug">Show Console</Button>
      </span>

    </Navbar>

    <div ref="dropTargets" class="mt-3">
      <Box
        class="m-auto mb-5"
        v-for="box in boxes"
        :key="box.id"
        :box="box"

        :onDragStart="dragStart"
        :onDragEnter="dragEnter"
        :onDragOver="dragOver"
        :onDragLeave="dragLeave"
        :onDragEnd="dragEnd"
        :onDrop="drop"

        :onClickBox="onClickBox"
      />
    </div>

    <div v-if="selectedBox && showDebug" class="rounded-md mx-5 bg-gray-800 text-white p-10">
      <Button class="bg-red-400 hover:bg-red-600 font-bold float-end" @click="showDebug = false">X</Button>
      <p v-html="printBox(selectedBox)"></p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import Box from "./Box.vue";
import Button from "./Button.vue";
import Navbar from "./Navbar.vue";
import GitHubButton from "./GitHubButton.vue";

import { defineProps, onMounted, ref, } from "vue";
import type { BoxComponentProps, } from "./Box.vue";

export interface BoxItem {
  draggable: boolean;
  isHide?: boolean;
  label: string;
}

export interface BoxProps {
  id: string;
  item: BoxItem;
  draggable: boolean;
  boxes: BoxProps[];
  parent?: BoxProps;
  isHover?: boolean;
  isEmpty?: boolean;
  isSelected?: boolean;
  isHide?: boolean;
}

/**
 * @param classes Optional classes to customize the appearance to the box.
 * @param classes.box.class box w-[150px] h-fit m-5 text-center rounded-md
 * @param classes.box.whenHaveParent ml-10
 * @param classes.box.whenHaveChildren border-l-2 border-dashed border-blue-300
 *
 * @param classes.item.isHover outline-blue-500 outline-dashed
 * @param classes.item.isEmpty outline-blue-500 outline-dashed
 * @param classes.item.isNotEmpty bg-blue-200 cursor-pointer
 * @param classes.item.isSelected bg-blue-400 shadow-lg shadow-blue-500/50
 * @param classes.item.notDraggable hover:bg-blue-300 shadow-lg hover:shadow-blue-500/50
 *
*/
const props = defineProps<{
  onDragStart?: (box: BoxProps) => void;
  onDragEnter?: (box: BoxProps) => void;
  onDragOver?: (box: BoxProps) => void;
  onDragLeave?: (box: BoxProps) => void;
  onDragEnd?: (box: BoxProps) => void;
  onDrop?: (box: BoxProps) => void;
  onClickOnTheBox?: (box: BoxProps) => void;

  boxClasses?: BoxComponentProps["classes"]
}>();

const dropTargets = ref<HTMLDivElement>();
const boxes = ref<BoxProps[]>([]);
const selectedBox = ref<BoxProps>();
const showMenu = ref(false);
const showDebug = ref(false);

let draggable: BoxProps | undefined;
let target: BoxProps | undefined;
let countBoxes = 0;

onMounted(() => {
  // const box = createBox();
  // const box2 = createBox();

  // box.boxes.push(box2);
  // box2.parent = box;
  // boxes.value.push(box);
});

function printBox(object: any, level = 0){
  const space = '&nbsp;&nbsp;'.repeat(level * 2); // Dois espaços por nível de profundidade
  let result = '';

  if(Array.isArray(object)){
    for (const item of object) {
      if(typeof item === 'object' && item){
        if(Object.keys(item).length === 0){
          result += `<span class="text-gray-400">{ }</span>,<br/>`;
        }else{
          result += `<span class="text-gray-400">{</span><br/>${printBox(item, level + 1)}${space}<span class="text-gray-400">}</span>,`;
        }
      } 
    }
  }else{
    for (const key in object) {
      if (Object.prototype.hasOwnProperty.call(object, key)) {
        const value = object[key];
        const formatedKey =  `<span class="text-blue-300">${key}</span>`;

        if(key === "parent"){
          if(value?.id){
            result += `${space}${formatedKey}: <span class="text-yellow-300">${value.id}</span>,<br/>`
          }else{
            result += `${space}${formatedKey}: <span class=\"text-blue-500\">undefined</span>,<br/>`
          }
        }else if (Array.isArray(value)) {
          if(value.length){
            result += `${space}${formatedKey}: <span class="text-gray-400">[</span><br/>${printBox(value, level + 1)}<br/>${space} <span class="text-gray-400">]</span>,<br/>`;
          }else{
            result += `${space}${formatedKey}: <span class="text-gray-400">[ ]</span>,<br/>`
          }
        } else if(typeof value === 'object' && value){
          if(Object.keys(value).length === 0){
            result += `${space}${formatedKey}: <span class="text-gray-400">{ }</span>,<br/>`;
          }else{
            result += `${space}${formatedKey}: <span class="text-gray-400">{</span><br/>${printBox(value, level + 1)}${space} <span class="text-gray-400">}</span>,<br/>`;
          }
        } else {
          const valueFormated = typeof value === 'string' ? `<span class="text-orange-400">"${value}"</span>` : `<span class="text-yellow-300">${value}</span>`;
          result += `${space}${formatedKey}: ${valueFormated},<br/>`;
        }
      }
    }
  }

  return result;
}

function dragStart(box: BoxProps) {
  draggable = box;

  setTimeout(() => {
    if(box.draggable){
      box.isHide = true;
      // console.log("hidden box => ", box.id);
    }else{
      box.item.isHide = true;
    }
  }, 0);
}

function dragEnter(box: BoxProps) {
  target = box;

  if(target.isEmpty) return;

  removeEmptyBoxes();
  
  if(!target.parent){
    // target.isHover = true;

    const boxIndex = boxes.value.findIndex(b => b.id === box.id);

    if(boxIndex !== -1 && !boxes.value[boxIndex]?.isEmpty){
      if(boxIndex === 0){
        boxes.value.unshift(createBox({ isEmpty: true }));
      }else if(boxIndex === (boxes.value.length -1)){
        boxes.value.push(createBox({ isEmpty: true }));
      }
    }
  }

  if(!target.boxes.find(b => b.isEmpty)){
    const newBox = createBox({ isEmpty: true });

    newBox.parent = target;
    target.boxes.push(newBox);
  }

  props.onDragEnter && props.onDragEnter(target);
}

function dragOver(box: BoxProps) {
  props.onDragOver && props.onDragOver(box);
}

function dragLeave(box: BoxProps) {
  props.onDragLeave && props.onDragLeave(box);
  // console.log("DRAG-LEAVE");
  // console.log("dragLeave box id => ", box.id);
  // console.log("dragLeave target.id => ", target?.id);

  // removeSendBoxes();

  // if(target){
  //   target.isHover = false;
  //   // target = undefined;
  // }
}

function drop() {
  // console.log("DROP target ID", target?.id);
  let boxesParentDraggable = boxes.value;

  if(target && draggable){
    target.isHover = false;

    if(draggable.parent){
      boxesParentDraggable = draggable.parent.boxes;
    }

    // ############ INICIO DO PROCESSO DE MUDANÇA DAS CAIXAS #############

    // Em caso de a caixa movida virar "filha de um filho";
    if(target?.parent?.id === draggable.id){
      // console.log("PARENT => ", target?.id);

      const targetCopy = { ...target };
      const draggableCopy = { ...draggable };

      draggableCopy.boxes = [];
      draggableCopy.parent = targetCopy;
      addChildToBox(targetCopy, draggableCopy);
      targetCopy.parent = draggable.parent;

      let draggableIndexInParent = 0;

      boxesParentDraggable.forEach((b, i) => {
        if(b === draggable){
          draggableIndexInParent = i;
        }
      });

      boxesParentDraggable[draggableIndexInParent] = targetCopy;

      // 3. ####################################
      //mover os filhos de draggable para o pai de draggable(draggable.parent);
      draggable.boxes = draggable.boxes.filter(b => b.id !== targetCopy.id);
      moveChildrenBoxToParent(boxesParentDraggable, draggable);
    }else{
      const draggableCopy = { ...draggable };

      if(!draggableCopy.draggable && draggableCopy.boxes.length){
        addChildToBox(draggable, draggable.boxes[0]);
        draggableCopy.boxes = [];
      }else{
        removeBox(draggable);
      }

      draggableCopy.parent = target.parent;
      draggableCopy.item.isHide = false;

      addChildToBox(target, draggableCopy);

      props.onDrop && props.onDrop(target);
    }
  }
}

function dragEnd() {
  // console.log("DRAG-END => target ID", target?.id);

  if(draggable){
    draggable.item.isHide = false;
    draggable.isHide = false;
  }

  if(target){
    target.isHover = false;
  }

  removeEmptyBoxes();
}

function addChildToBox(box: BoxProps, child: BoxProps){
  box.item = child.item;
  box.isEmpty = false;
  box.boxes = child.boxes;
  box.draggable = child.draggable;
  box.isHide = false;
}

//mover os filhos de draggable para o pai de draggable(draggable.parent);
function moveChildrenBoxToParent(parentDraggable: BoxProps[], draggable: BoxProps){
  draggable.boxes.forEach(b => {
    b.parent = draggable.parent;
    parentDraggable.push(b);
  });
}

function onClickBox(box: BoxProps){
  showMenu.value = true;
  box.isSelected = true;
  selectedBox.value = box;

  const validate = (_box: BoxProps) => {
    return _box.id !== box.id;
  };

  const onFind = (box: BoxProps) => {
    box.isSelected = false;
  };

  onFindBox({ validate, onFind });
}

function addChildInSelectedBox(){
  const validate = (box: BoxProps) => {
    return box.id === selectedBox?.value?.id;
  };

  const onFind = (box: BoxProps) => {
    const newBox = createBox();

    newBox.parent = box;
    box.boxes.push(newBox);
  };

  onFindBox({ validate, onFind, options: { stopWhenFind: true } });
}

function createBox(boxOptions?: { isEmpty?: boolean }){
  countBoxes++;

  const newBox = {
    id: String(countBoxes),
    draggable: false,
    boxes: [],
    item: {
      label: "t" + countBoxes,
      draggable: true,
      isHide: false
    },
    ...boxOptions
  } as BoxProps;

  return newBox;
}

function addBox(box?: BoxProps){
  const newBox: BoxProps = createBox();

  newBox.parent = box;

  if(box){
    box.boxes.push(newBox);
  }else{
    boxes.value.push(newBox);
  }
}

function removeEmptyBoxes(){
  const validate = (box: BoxProps) => {
    return !!(box.isEmpty);
  };

  const onFind = (box: BoxProps, i: number) => {
    if(box.parent){
      box.parent.boxes.splice(i, 1);
    }else{
      boxes.value.splice(i, 1);
    }
  };

  onFindBox({ validate, onFind });
}

interface onFindBoxProps {
  validate: (box: BoxProps) => boolean,
  onFind: (box: BoxProps, index: number) => void,
  box?: BoxProps,
  options?: { stopWhenFind?: boolean }
}

function onFindBox({
  validate,
  onFind,
  box,
  options
}: onFindBoxProps) {
  const _boxes = box?.boxes ?? boxes.value as BoxProps[];

  for (let i = 0; i < _boxes.length; i++) {
    const _box = _boxes[i];

    if(validate(_box)){
      onFind(_box, i);

      if(options?.stopWhenFind){
        return
      }
    }

    onFindBox({ validate, onFind, box: _box, options });
  }
}

// ########################## MENU ###################################

function handleGroup(){
  if(selectedBox.value){
    selectedBox.value.draggable = !selectedBox.value.draggable ?? true;
    selectedBox.value.item.draggable = !selectedBox.value.item.draggable;
  }
}

function removeBox(boxToRemove?: BoxProps){
  const validate = (box: BoxProps) => {
    return box.id === boxToRemove?.id;
  };

  const onFind = (box: BoxProps, i: number) => {
    if(box.parent){
      box.parent.boxes.splice(i, 1);
    }else{
      boxes.value.splice(i, 1);
    }
  };

  onFindBox({ validate, onFind });
  showMenu.value = false;
}

</script>