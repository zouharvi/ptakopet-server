export KERAS_BACKEND=theano

echo "Analysing input parameters"

task_name="word_en_de"
src="src"
trg="mt"
score="hter"
out_activation="sigmoid"
device="cpu"

# we copy the base config
conf=config-wordQEbRNN.py
model_type=EncWord
model_name=${task_name}_${src}${trg}_${model_type}
store_path=trained_models/${model_name}/
patience=10
rnd_seed=8

rm -rf config.*
ln -s ../configs/$conf ./config.py

echo "Traning the model "${model_name}
THEANO_FLAGS=device=$device python2 main.py TASK_NAME=$task_name DATASET_NAME=$task_name DATA_ROOT_PATH=examples/${task_name} SRC_LAN=${src} TRG_LAN=${trg} PRED_SCORE=$score OUT_ACTIVATION=$out_activation MODEL_TYPE=$model_type MODEL_NAME=$model_name STORE_PATH=$store_path NEW_EVAL_ON_SETS=val PATIENCE=$patience SAVE_EACH_EVALUATION=True RND_SEED=$rnd_seed > log-${model_name}-prep.txt 2> log-${model_name}-prep-error.txt

awk '/^$/ {nlstack=nlstack "\n";next;} {printf "%s",nlstack; nlstack=""; print;}' log-${model_name}-prep-error.txt > log-${model_name}-error.txt
best_epoch=$(tail -1 log-${model_name}-error.txt | tr ':' '\n' | tr ' ' '\n' | tail -5 | head -1)

# pre-trained Weights + Vocab to use for scoring
pred_vocab=saved_models/${model_name}/Dataset_${task_name}_${src}${trg}.pkl
pred_weights=saved_models/${model_name}/epoch_${best_epoch}_weights.h5

mkdir -p saved_models/${model_name}
cp datasets/Dataset_${task_name}_${src}${trg}.pkl saved_models/${model_name}
cp trained_models/${model_name}/epoch_${best_epoch}_weights.h5 saved_models/${model_name}

echo 'Best model weights are dumped into 'saved_models/${model_name}/epoch_${best_epoch}_weights.h5

# remove created symlink
rm -rf config.*